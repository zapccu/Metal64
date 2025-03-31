//
//  operations.cpp, part of float64
//
//  Emulation of 64 bit floating point numbers
//
//  Original Code by Detlef_a (Nickname in the www.mikrocontroller.net forum).
//  Extensions (trigonometric functions et al.) und changes by Florian Königstein, mail@virgusta.eu .
//
//  Reference: https://www.mikrocontroller.net/topic/85256
//
//  Ported to C++, adapted to MacOS / Metal by Dirk Braner on 27.12.24.
//

#ifdef __METAL_VERSION__
#include <metal_stdlib>
#endif

#include "complex64.h"

#ifdef __METAL_VERSION__
using namespace metal;
#endif

// ------------------------------------
//  float64 operations
// ------------------------------------

float64_t f_abs(float64_t x) {
    return x & 0x7fffffffffffffff;
}

float64_t f_add(float64_t a, float64_t b) {
    uint8_t     signa,signb,signerg;
    uint8_t     flagexd;
    uint64_t    i64;
    TPTR float64_t*  x = &i64;
 
    signa = f_getsign(a);
    signb = f_getsign(b);
    
    if(signa ^ signb) {
        f_addsub2(x, a, b, 0, &flagexd);
        signerg = ((flagexd ^ signa)) & 1;
    }
    else {
        f_addsub2(x, a, b, 1, &flagexd);
        signerg = signa;
    }
    // f_setsign(x,signerg);

    // return(i64);
    return f_setsign(i64, signerg);
}

float64_t f_sub(float64_t a, float64_t b) {
    uint8_t   signb;
    float64_t bloc = b;
    uint64_t  i64;
 
    signb = f_getsign(bloc);
    signb ^= 1;
    //f_setsign(&bloc, signb);
    bloc = f_setsign(bloc, signb);
    i64 = f_add(a, bloc);
    
    return(i64);
}

float64_t f_mul(float64_t fa, float64_t fb) {
    uint8_t  asig,bsig;
    int16_t aex,bex;
    uint64_t am, bm;
  
    //f_split64(&fa, &asig, &aex, &am, 11);
    //f_split64(&fb, &bsig, &bex, &bm, 11);
    f_split64(fa, &asig, &aex, &am, 11);
    f_split64(fb, &bsig, &bex, &bm, 11);

    if(2047 == aex) {
        if(0 != am || (2047 == bex && 0 != bm) || 0 == bex)
            return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }
    else if(2047 == bex) {
        if(0 != bm || 0 == aex)
            return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
        aex = bex;
        am = bm;
    }
    else if(!aex || !bex) {
        return FLOAT64_NUMBER_PLUS_ZERO;
    }
    else {
        aex = aex + bex - (0x3ff + 10);
        am = approx_high_uint64_word_of_uint64_mult_uint64(&am, &bm, 0);
    }
    
    asig ^= bsig;
    f_combi_from_fixpoint(&fa, asig, aex, &am);

    return fa;
}


float64 mul(float64 a, float64 b) {
    uint8_t  asig,bsig;
    int16_t aex,bex;
    uint64_t am, bm;
  
    //f_split64(&a.v, &asig, &aex, &am, 11);
    //f_split64(&b.v, &bsig, &bex, &bm, 11);
    f_split64(a.v, &asig, &aex, &am, 11);
    f_split64(b.v, &bsig, &bex, &bm, 11);
  
    if(2047 == aex) {
        if(0 != am || (2047 == bex && 0 != bm) || 0 == bex)
            return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }
    else if(2047 == bex) {
        if(0 != bm || 0 == aex)
            return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
        aex = bex;
        am = bm;
    }
    else if(!aex || !bex) {
        return FLOAT64_NUMBER_PLUS_ZERO;
    }
    else {
        aex = aex + bex - (0x3ff + 10);
        am = approx_high_uint64_word_of_uint64_mult_uint64(&am, &bm, 0);
    }
    
    asig ^= bsig;
    f_combi_from_fixpoint(&a.v, asig, aex, &am);

    return a;
}

/// Divide values
float64_t f_div(float64_t x, float64_t y) {
    uint8_t  xsig, ysig;
    int16_t xex, yex;
    uint64_t xm, ym, i64;

    // f_split64(&x, &xsig, &xex, &xm, 11);
    //f_split64(&y, &ysig, &yex, &ym, 11);
    f_split64(x, &xsig, &xex, &xm, 11);
    f_split64(y, &ysig, &yex, &ym, 11);

    if(0 == yex) { // divide by 0 wont work
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }
    else if(2047 == xex) {
        if(0 != xm || 2047 == yex)
            return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
        return (xsig ^ ysig) ? FLOAT64_MINUS_INFINITY : FLOAT64_PLUS_INFINITY;
    }
    else if(2047 == yex) {
        if(0 == ym)
            return FLOAT64_NUMBER_PLUS_ZERO;
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }

    else
    {
        i64 = approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(&xm, approx_inverse_of_fixpoint_uint64(&ym), 0);
        xex += 1023 - yex;
    }
    f_combi_from_fixpoint(&x, xsig^ysig, xex-10, &i64);
    
    return x;
}

/// Compare values
int8_t f_compare(float64_t x, float64_t y) {
    // If both x and y represent real numbers
    // (or +/-INF if F_ONLY_NAN_NO_INFINITY is not defined) f_compare returns
    // zero if x is equal to y, positive nonzero if x > y and negative nonzero if x < y.
    // If x or y are NaN, f_compare returns zero.
    uint8_t asig,bsig;
    int16_t xex,yex;
    uint64_t wx, wy;
    
    // f_split64(&x, &asig, &xex, &wx, 0);
    // f_split64(&y, &bsig, &yex, &wy, 0);
    f_split64(x, &asig, &xex, &wx, 0);
    f_split64(y, &bsig, &yex, &wy, 0);

    if((2047 == xex && 0 != wx) || (2047 == yex && 0 != wy)) // x=NaN or y=NaN
        return 0;
    if(2047 == xex) { // x = +INF or -INF
        if(2047 == yex) // y = +INF or -INF
            return asig == bsig ? 0 : (asig ? -1 : 1);
        else
            return asig ? -1 : 1;
    }
    if(2047 == yex) // y = +INF or -INF
        return bsig ? 1 : -1;
    if(0 == xex) // x = 0
        return (0 == yex && 0 == wy) ? 0 : (bsig ? 1 : -1);
    if(0 == yex || asig != bsig || xex > yex)
        return asig ? -1 : 1;
    if(xex < yex)
        return asig ? 1 : -1;
    
    return wx == wy ? 0 : ((wx > wy && !asig) || (wx < wy && asig) ? 1 : -1);
}

/// Square root
float64_t f_sqrt(float64_t x) {
    uint8_t xsig;
    int16_t xex;
    uint64_t w, wL;

    //f_split64(&x, &xsig, &xex, &w, 11);
    f_split64(x, &xsig, &xex, &w, 11);
    if (0 == xex)
        return FLOAT64_NUMBER_PLUS_ZERO;
    if(2047 == xex) {
        if(0 == w && 0 == xsig)
            return x;
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }
    if(xsig)
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;

    wL = 0;
    if (xex & 1) {
        if(w & 1)
            wL = ((uint64_t)1LU) << 63;
        w >>= 1;
    }

    w = rounded_sqrt_of_integer128(w, wL);
    f_combi_from_fixpoint(&x, 0, (xex + 1) / 2 + 500, &w);
    
    return x;
}

/// Exponential function
float64_t f_exp(float64_t x) {
    uint8_t f_sign, f_sign2;
    int16_t f_ex;
    float64_t g, rest;
    int16_t gi;
    uint64_t w, w2;
    uint64_t interp[] = {
        0x00000025f42ff241, 0x00000112e79387f1, 0x00000ba525a70ff3, 0x000067f7ce0d91cb,
        0x0003403a635c5891, 0x0016c16a4128d5ee, 0x00888888e10886ed, 0x02aaaaaaa0251d3e,
        0x0aaaaaaaab66a1c0, 0x1ffffffffff9434d, 0x400000000000180b, 0x3ffffffffffffff2
    };
    
    //f_split64(&x, &f_sign, &f_ex, &w, 0);
    f_split64(x, &f_sign, &f_ex, &w, 0);

    if (0 == f_ex)
        return FLOAT64_NUMBER_ONE;

    if (2047 == f_ex) {
        if(0 != w || (0 == w && 0 == f_sign))
            return x;
        return FLOAT64_NUMBER_PLUS_ZERO;
    }
    if (f_ex >= 1023 + 10)
        return f_sign ? FLOAT64_NUMBER_PLUS_ZERO : FLOAT64_PLUS_INFINITY;

    w = 0xb17217f7d1cf79ac; // Mantisse of log(2)
    rest = f_mod_intern(f_abs(x), 0, 1022, &w, &g); // Modulo log(2)
    //f_split_to_fixpoint(&rest, &f_sign2, &f_ex, &w2, 64);
    f_split_to_fixpoint(rest, &f_sign2, &f_ex, &w2, 64);
    if(f_ex <= 1022 - 64)
        w = 0;
    else
        w >>= 1022 - f_ex;
    gi = f_float64_to_long(g);

    if(f_sign2)
        w = 0;
    else if(f_ex >= 1023) // Rundungsfehler bei f_mod
        w = 0xffffffffffffffff;

    w = f_eval_function_by_rational_approximation_fixpoint(w, 12, 0, interp, 0);

    if (f_sign) {
        gi -= f_shift_left_until_bit63_set(&w);
        w = approx_inverse_of_fixpoint_uint64(&w);
    }
    f_combi_from_fixpoint(&g, 0, f_sign ? (1021 - 10) - gi : (1023 - 10) + gi, &w);

    return g;
}

/// Natural logarithm
float64_t f_log(float64_t x) {
    uint8_t f_sign;
    int8_t sgnw2 = 0;
    int16_t f_ex, f_ex2;
    uint64_t w, w2;
    uint64_t interp[] = {
        0x00020306b29459c0, 0x0059c8a974126d6a, 0x03f628260c2db8e4, 0x11dfa5d2d89584a5,
        0x255cf1f4fada2dcc, 0x243348927d4a6bdf, 0x0d22e971210e91e5, 0x00005e30ad9c1880,
        0x001a68f2d08c85a8, 0x01b09953e747fe7e, 0x0af24b95490068ee, 0x2215f7d0824727db,
        0x365e581f76be278e, 0x2ac4bd4b0dd1b53c, 0x0d22e971210e91e6
    };

    //f_split64(&x, &f_sign, &f_ex, &w, 11);
    f_split64(x, &f_sign, &f_ex, &w, 11);

    if(0 == f_ex)
        return FLOAT64_MINUS_INFINITY;
    if(2047 == f_ex || 0 != f_sign) {
        if(0 == w && 0 == f_sign) // +INF
            return x;
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION; // -INF
    }

    if(1022 == f_ex && w >= 0xe000000000000000) {
        w = (0xffffffffffffffff+1) - w;
        sgnw2 = -1;
    }
    else {
        w2 = f_ex-1023;
        if(f_ex < 1023) {
            w2 = -w2;
            sgnw2 = -2;
        }
        else if(f_ex > 1023)
            sgnw2 = 1;
        
        w <<= 1;
    }

    f_ex = (1022-9) - f_shift_left_until_bit63_set(&w);

    if(0 != w)
        w = approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(&w,
            f_eval_function_by_rational_approximation_fixpoint(w >> ((1022 - 9) - f_ex), 7, 8, interp, -1 == sgnw2 ? 3 : 0), 0);

    if(0 == sgnw2 || -1 == sgnw2)
        f_ex2 = f_ex;
    else {
        f_ex2 = (1023 + 63 - 11) - f_shift_left_until_bit63_set(&w2);
        w2 = approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(&w2, 0xb17217f7d1cf79ac, 0);
        if(f_ex2 >= f_ex)
            (f_ex2 - f_ex >= 64) ? (w = 0) : (w >>= (f_ex2 - f_ex));
        else
            w <<= (f_ex - f_ex2);
        if(sgnw2 >= 0)
            w += w2;
        else
            w = w2 - w;
    }

    f_combi_from_fixpoint(&x, sgnw2 < 0 ? 1 : 0, f_ex2, &w);
    return x;
}

/// Power of float64_t, ffloat64_t
float64_t f_pow(float64_t a, float64_t b) {
    return f_exp(f_mul(b, f_log(a)));
}

/// Power of float64_t, int
float64_t f_pow(float64_t a, int b) {
    float64_t r = 1.0f;
    int i;
    
    for (i=0; i<b; i++) {
        r = f_mul(r, a);
    }
    
    return r;
}


// ------------------------------------
//  complex64 operations
// ------------------------------------

// Multiply 2 64 bit complex values
complex64 c_mul(complex64 a, complex64 b) {
    float64_t r1 = f_mul(a.r.v, b.r.v);    // a.r * b.r
    float64_t r2 = f_mul(a.i.v, b.i.v);    // a.i * b.i
    float64_t i1 = f_mul(a.r.v, b.i.v);    // a.r * b.i
    float64_t i2 = f_mul(a.i.v, b.r.v);    // a.i * b.r
    return complex64(f_sub(r1, r2), f_add(i1, i2));
}

// Square of 64 bit complex value
complex64 c_sqr(complex64 a) {
    float64_t r1 = f_mul(a.r.v, a.r.v);
    float64_t r2 = f_mul(a.i.v, a.i.v);
    float64_t i1 = f_mul(a.r.v, a.i.v);
    return complex64(f_sub(r1, r2), f_add(i1, i1));
}

// Divide 2 64 bit complex values
complex64 c_div(complex64 a, complex64 b) {
    float64_t d = f_add(f_mul(b.r.v, b.r.v), f_mul(b.i.v, b.i.v));
    float64_t r = f_div(f_add(f_mul(a.r.v, b.r.v), f_mul(a.i.v, b.i.v)), d);
    float64_t i = f_div(f_sub(f_mul(a.i.v, b.r.v), f_mul(a.r.v, b.i.v)), d);
    return complex64(r, i);
}

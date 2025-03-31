//
//  helpers.cpp, part of float64
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

#include "float64.h"

#ifdef __METAL_VERSION__
using namespace metal;
#endif

void f_setsign(TPTR float64_t *x, int8_t sign) {
    if(sign)
        *x |= 0x8000000000000000;
    else
        *x &= 0x7fffffffffffffff;
}

float64_t f_setsign(float64_t x, int8_t sign) {
    return sign ? x |= 0x8000000000000000 : x &= 0x7fffffffffffffff;
}

uint8_t f_getsign(float64_t x) {
//    uint64_t * px = &x;
//    return ((uint8_t)(((*px) >> 63) & 1));
    return ((uint8_t)((x >> 63) & 1));
}

/*
void f_split64(TPTR float64_t *x, TPTR uint8_t *f_sign, TPTR int16_t *f_ex, TPTR uint64_t *frac, uint8_t lshift) {
    *frac = (*x) & 0xfffffffffffff;
    if (0 == (*f_ex = (((*x) >> 52) & 2047)))
        *frac = 0;
    else if (2047 != (*f_ex))
        *frac |= 0x10000000000000;
    *frac <<= lshift;
    *f_sign = ((*x) >> 63) & 1;
}
*/

void f_split64(float64_t x, TPTR uint8_t *f_sign, TPTR int16_t *f_ex, TPTR uint64_t *frac, uint8_t lshift) {
    *frac = x & 0xfffffffffffff;
    if (0 == (*f_ex = ((x >> 52) & 2047)))
        *frac = 0;
    else if (2047 != (*f_ex))
        *frac |= 0x10000000000000;
    *frac <<= lshift;
    *f_sign = (x >> 63) & 1;
}

/*
void f_split_to_fixpoint(TPTR float64_t *x, TPTR uint8_t *f_sign, TPTR int16_t *f_ex, TPTR uint64_t *frac, int16_t point_bitnr) {
    f_split64(*x, f_sign, f_ex, frac, 0);
    if(0!=(*f_ex) && 2047!=(*f_ex))
    {
        point_bitnr=(1023+52)-(*f_ex)-point_bitnr;
        if(point_bitnr<=-64 || point_bitnr>=64)
            *frac=0;
        else if(point_bitnr<0)
            *frac<<=-point_bitnr;
        else
            *frac>>=point_bitnr;
    }
}
*/

void f_split_to_fixpoint(float64_t x, TPTR uint8_t *f_sign, TPTR int16_t *f_ex, TPTR uint64_t *frac, int16_t point_bitnr) {
    f_split64(x, f_sign, f_ex, frac, 0);
    if (0 != (*f_ex) && 2047 != (*f_ex)) {
        point_bitnr = (1023 + 52) - (*f_ex) - point_bitnr;
        if (point_bitnr <= -64 || point_bitnr >= 64)
            *frac = 0;
        else if (point_bitnr < 0)
            *frac <<= -point_bitnr;
        else
            *frac >>= point_bitnr;
    }
}

void f_combi_from_fixpoint(TPTR float64_t* x, uint8_t f_sign, int16_t f_ex, TPTR uint64_t* frac) {
    uint8_t round = 0;
    uint64_t w = *frac;
    if (0 != w) {
        while (0 == (w & 0xffffe00000000000)) {
            w <<= 8;
            f_ex -= 8;
        }
        while (0 == (w & 0xfff0000000000000)) {
            w <<= 1;
            --f_ex;
        }
        while (0 != (w & 0xff00000000000000)) {
            round = 0 != (w & (1 << 3));
            w >>= 4;
            f_ex += 4;
        }
        while (0 != (w & 0xffe0000000000000)) {
            round = 0 != (w & 1);
            w >>= 1;
            ++f_ex;
        }
        if (round) {
            ++w;
            if(0 != (w & 0xffe0000000000000))
            {
                w >>= 1;
                ++f_ex;
            }
        }
        if (f_ex <= 0) {
            f_ex = 0;
            w = 0;
        }
    }
    else if(f_ex < 2047)
        f_ex = 0;
    if(f_ex >= 2047) {
        f_ex = 2047;
        w = 0;
    } // +INF or -INF
    
    *((TPTR uint64_t*)x) = (((uint64_t)f_sign) << 63) | (((uint64_t)f_ex) << 52) | (w & 0xfffffffffffff);
}

int8_t f_shift_left_until_bit63_set(TPTR uint64_t *w) {
    int8_t count=0;
    uint64_t mask;
    
    for(mask=((uint64_t)255LU) << (63 - 7); 0==(mask & (*w)) && count < 64; count += 8)
        (*w) <<= 8;
    for(mask=((uint64_t)1LU) << 63; 0 == (mask & (*w)) && count < 64; ++count)
        (*w) <<= 1;
    
    return count;
}

uint64_t approx_high_uint64_word_of_uint64_mult_uint64(TPTR uint64_t *x, thread uint64_t *y, uint8_t signed_mult) {
    // Calculate an approximation of floor(x * y / (2 ^ 64))
    uint64_t r = ((*x) >> 32) * ((*y) >> 32) + ((((*x) >> 32) * ((*y) & 0xffffffff)) >> 32) + ((((*y) >> 32) * ((*x) & 0xffffffff)) >> 32);
    if (0 != (signed_mult & 1) && ((int64_t)(*x)) < 0)
        r -= (*y);
    if (0 != (signed_mult & 2) && ((int64_t)(*y)) < 0)
        r -= (*x);
    return r;
}

uint64_t approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(TPTR uint64_t *x, uint64_t y, uint8_t signed_mult) {
    return approx_high_uint64_word_of_uint64_mult_uint64(x, &y, signed_mult);
}

uint64_t approx_inverse_of_fixpoint_uint64(TPTR uint64_t *y) {
    // if 0 != *y & 0x8000000000000000
    // Calculate approximation for (2 ^ 126) / *y
    uint64_t yv = *y, z8, k5;
    uint16_t z3;
    uint32_t z5 = (yv >> 32), z6, k;
    uint8_t c;

    if (0 != (((unsigned long)yv)&0x80000000) && 0 == ++z5)
        z6=0;
    else {
        z3 = (z5 >> 16);

        if (0 == (z3 & 0x7fff)) {
            if(0 == (z5 & 0xffff))
                return (0xffffffffffffffff + 1) - yv;
            z6 = -((z5&0xffff) << 2);
        }
        else if (0xffff == z3)
            z6 = -z5;
        else {
            z3 = (uint16_t)(1 + (0xffffffff-(z3 >> 1)) / z3);
            z6 = (((uint32_t)z3) << 17) - (z5 + ((z3 * ((0x20000 + (uint32_t)z3) * (uint64_t)z5)) >> 32)) - 1;
        }
    }

    for(k=(uint32_t)(k5=(0x100000000 | ((uint64_t)z6))*z5 + (z5>>1)), c=k5>>32 ; 0!=c ; )
    {
        if (k + z5 < k) ++c; // Break loop after 8 bit overflow
        k += z5;
        ++z6;
    }

    z8=(((uint64_t)1LU)<<63) | ((uint64_t)z6)<<31;

    k5 = (0xffffffffffffffff + 1) - z8 - approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(&z8, yv<<1, 0); // Bei yv<<1 geht das hˆchstwertigste Bit verloren
    z8 = approx_high_uint64_word_of_uint64_mult_uint64(&z8, &k5, 0) + ((0==(k5&0x8000000000000000)) ? z8 : 0);
    return (z8+1) >> 1;
}

uint64_t f_eval_function_by_rational_approximation_fixpoint(uint64_t x, uint8_t anz_zaehler, uint8_t anz_nenner, TPTR uint64_t *koeffs, uint8_t signed_mult) {
    uint64_t zz, nn;
    uint8_t sh;

    if(0 == anz_zaehler)
        zz = 0x800000000000000;
    else
        for(zz=0 ; (((0==(signed_mult & 2) || 0!=(anz_zaehler&1)) ? (zz+=*koeffs) : (zz-=*koeffs)), koeffs++, 0!=--anz_zaehler) ; )
            zz = approx_high_uint64_word_of_uint64_mult_uint64(&zz, &x, signed_mult & 1);

    if(0 == anz_nenner)
        return zz;
    
    for(nn=0 ; (((0==(signed_mult & 2) || 0!=(anz_nenner&1)) ? (nn+=*koeffs) : (nn-=*koeffs)), koeffs++, 0!=--anz_nenner) ; )
        nn = approx_high_uint64_word_of_uint64_mult_uint64(&nn, &x, signed_mult & 1);

    sh=0;
    while(0 == (0xff00000000000000 & nn)) {
        nn <<= 8;
        if(0 == (0xff00000000000000 & zz))
            zz <<= 8;
        else
            sh += 8;
    }
    while(0 == (0x8000000000000000 & nn)) {
        nn <<= 1;
        if(0 == (0x8000000000000000 & zz))
            zz <<= 1;
        else
            ++sh;
    }
    nn = approx_inverse_of_fixpoint_uint64(&nn);
    
    return approx_high_uint64_word_of_uint64_mult_uint64(&zz, &nn, 0) << sh;
}

void f_addsub2(TPTR float64_t* x, float64_t a, float64_t b, uint8_t flagadd, TPTR uint8_t *flagexd ) {
    uint8_t sig;
    int16_t aex,bex;
    uint64_t wa, wb;

    //f_split64(&a, &sig, &aex, &wa, 10);
    //f_split64(&b, &sig, &bex, &wb, 10);
    f_split64(a, &sig, &aex, &wa, 10);
    f_split64(b, &sig, &bex, &wb, 10);

    *flagexd = 0;

    if(2047 == aex) {
        if(0 == wa && (2047 != bex || (0 == wb && flagadd)))
            *x = a;
        else
            *x = FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
        return;
    }
    else if(2047 == bex) {
        *x = b;
        return;
    }

    if(!aex || aex + 64 <= bex) {
        *x = b;
        *flagexd = 1;
        return;
    }
    if(!bex || bex + 64 <= aex) {
        *x = a;
        return;
    }

    if(flagadd)
    {
        if(aex >= bex)
            wa += wb >> (aex - bex);
        else
        {
            wa = wb + (wa >> (bex - aex));
            aex = bex;
        }
    }
    else {
        if(aex>bex || (aex==bex && wa>=wb))
            wa -= wb >> (aex - bex);
        else {
            wa = wb - (wa >> (bex - aex));
            *flagexd = 1;
            aex = bex;
        }
    }
    f_combi_from_fixpoint(x, 0, aex - 10, &wa);
}

long f_float64_to_long(float64_t x) {
    uint8_t f_sign;
    int16_t f_ex;
    uint64_t w;
    //f_split_to_fixpoint(&x, &f_sign, &f_ex, &w, 0);
    f_split_to_fixpoint(x, &f_sign, &f_ex, &w, 0);
    return (f_ex >= 1023 + 32) ? 0 : (f_sign ? -((long)w) : ((long)w));
}

uint64_t rounded_sqrt_of_integer128(uint64_t x_high, uint64_t x_low) {
    uint64_t rL=0, rH=0, sH, sL;
    uint8_t i;
    for(i=2*64; 0!=i; ) {
        i -= 2;
        sH = rH;
        sL = rL;
        if (i >= 64)
            sH += ((uint64_t)1LU) << (i - 64);
        else {
            if (sL >= (uint64_t)(-(((uint64_t)1LU) << i)))
                sH++;
            sL += ((uint64_t)1LU) << i;
        }

        rL >>= 1;
        if(rH & 1)
            rL |= ((uint64_t)1LU) << 63;
        rH >>= 1;

        if(sH<x_high || (sH==x_high && sL<=x_low)) {
            x_high -= sH;
            if(sL > x_low)
                --x_high;
            x_low -= sL;
            if(i >= 64)
                rH |= ((uint64_t)1LU) << (i-64);
            else
                rL |= ((uint64_t)1LU) << i;
        }
    }
    return (0 != x_high || x_low >= rL) && 0xffffffffffffffff != rL ? rL + 1 : rL;
}

float64_t f_mod_intern(float64_t x, uint8_t ysig, int16_t yex, TPTR uint64_t *ymts, TPTR float64_t *ganz) {
    uint8_t xsig, count;
    int16_t xex, zex;
    uint64_t xm;
    float64_t g;
    uint64_t q;

    //f_split64(&x, &xsig, &xex, &xm, 11);
    f_split64(x, &xsig, &xex, &xm, 11);
    if (ganz)
        *ganz = FLOAT64_NUMBER_PLUS_ZERO;
    if(0 == xex)
        return FLOAT64_NUMBER_PLUS_ZERO;
    if(2047 == xex || 2047 == yex || 0 == (yex|(*ymts)))
    {
        if(ganz)
            *ganz = FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
        return FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    }

    for(count=10 ; 0!=(xex|xm) && (xex>yex || (xex==yex && xm>=(*ymts))) && 0!=--count ; ) {
        q = approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(&xm, (approx_inverse_of_fixpoint_uint64(ymts)-5)<<1, 0)-5;
        if (xex == yex && 0 == (0x8000000000000000 & q))
            q = 0x8000000000000000;
        zex = xex - yex;
        if(zex <= 63)
            q &= (0xffffffffffffffff << (63 - zex));
        xm -= approx_high_uint64_word_of_uint64_mult_uint64(&q, ymts, 0)<<1;

        if(ganz)
        {
            f_combi_from_fixpoint(&g, xsig^ysig, (1023-11)+zex, &q);
            *ganz=f_add(*ganz, g);
        }
        xex-=f_shift_left_until_bit63_set(&xm);
    }
    f_combi_from_fixpoint(&x, xsig, xex-11, &xm);
    *ymts = xm;
    if(0 == count)
        return FLOAT64_NUMBER_PLUS_ZERO;
    return x;
}

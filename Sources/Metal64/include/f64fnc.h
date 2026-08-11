//
//  f64fnc.h
//  Metal64
//
//  Created by Dirk Braner on 23.12.24.
//
//  64 bit real float:
//
//    A 64 bit float value is represented by float2 data type.
//    The corresponding Swift data types are SIMD2<Float32> and Float2.
//      .x = High value part
//      .y = Low value part
//
//  64 bit complex float:
//
//    A 64 bit complex value is represented by float4 data type.
//    The corresponding Swift data type is SIMD4<Float32> and Complex2.
//      .xy = float2 with real part high, low
//      .zw = float2 with imaginary part high, low
//
//  References:
//
//    "Extended-Precision Floating-Point Numbers for GPU Computation"
//    Andrew Thall, Alma College
//
//    CORDIC algorithms: https://people.sc.fsu.edu/~jburkardt/c_src/cordic/cordic.html
//

#ifndef __F64FNC_H
#define __F64FNC_H

using namespace metal;


// ----------------------------------------------------------------------------
//  Constants
// ----------------------------------------------------------------------------

static constant float2 F2_PI     = float2(3.1415927,   -8.742278e-08);   // PI
static constant float2 F2_1_PI   = float2(0.31830987,   1.28412765e-08); // 1 / PI
static constant float2 F2_2_PI   = float2(6.2831855,   -1.7484555e-07);  // PI * 2
static constant float2 F2_PI_2   = float2(1.5707964,   -4.371139e-08);   // PI / 2
static constant float2 F2_PI_180 = float2(0.017453292,  1.351996e-10);   // PI / 180
static constant float2 F2_LOG2   = float2(0.6931472,   -1.9046542e-09);  // LOG(2)
static constant float2 F2_1_LOG2 = float2(1.442695,     1.925963e-08);   // 1 / LOG(2)
static constant float2 F2_E      = float2(2.7182817,    8.2548404e-08);  // E
static constant float2 F2_1_E    = float2(0.36787945,  -9.149755e-09);   // 1 / E
static constant float2 F2_1_3    = float2(0.33333334,  -9.934108e-09);   // 1 / 3
static constant float2 F2_1_5    = float2(0.2,         -2.9802323e-09);  // 1 / 5
static constant float2 F2_1_7    = float2(0.14285715,  -6.386212e-09);   // 1 / 7
static constant float2 F2_1_9    = float2(0.11111111,  -8.278423e-10);   // 1 / 9
static constant float2 F2_1_11   = float2(0.09090909,  -2.7093021e-09);
static constant float2 F2_1_13   = float2(0.07692308,  -2.865608e-09);
static constant float2 F2_1_15   = float2(0.06666667,  -3.4769376e-09);
static constant float2 F2_1_17   = float2(0.05882353,  -2.1913472e-10);
static constant float2 F2_1_19   = float2(0.05263158,  -3.9213582e-10);
static constant float2 F2_1_21   = float2(0.04761905,  -8.869739e-10);
static constant float2 F2_1_23   = float2(0.04347826,  -8.0984575e-10);

static constant float2 F2_ZERO   = 0.0f;
static constant float2 F2_ONE    = float2(1.0f, 0.0f);
static constant float4 F4_ONE    = float4(1.0f, 0.0f, 0.0f, 0.0f);

// exp(x) > 0 for all x, but float32 overflow at:
static constant float2 F2_EXPMAX = float2(88.02969f,  2.6030809e-07f);  // 127 * ln(2)
static constant float2 F2_EXPMIN = float2(-87.33655f, 2.3201194e-07f);  // -126 * ln(2)


// ----------------------------------------------------------------------------
//  Declare functions
// ----------------------------------------------------------------------------

static float2 log_remez(float2);
static float4 sincos_iterate(float2);
static float2 tan_iterate(float2);
static float2 asin_iterate(float2);
static float2 acos_iterate(float2);
static float2 atan2_iterate(float2, float2);
static float2 exp_iterate(float2);
static float2 log_iterate(float2);

static inline float2 flt2(float);

static inline float2 floor_f64(float2);
static inline float2 abs_c64(float4);


// ----------------------------------------------------------------------------
//  Helper functions
// ----------------------------------------------------------------------------

// Convert float32 to float2
static inline float2 flt2(float a) {
    return float2(a, 0.0f);
}

// Convert float32 to float4
static inline float4 flt4(float a) {
    return float4(a, 0.0f, 0.0f, 0.0f);
}

// Convert float2 to float4
static inline float4 flt4(float2 a) {
    return float4(a.x, a.y, 0.0f, 0.0f);
}

// Fast normalization (single pass)
// Ensure, that |a.y| <= 0.5 * f64_epsilon of a.x
static inline float2 quick_renorm(float2 a) {
    float s = a.x + a.y;
    float e = a.y - (s - a.x);
    return float2(s, e);
}

// Full normalization (two pass)
static inline float2 full_renorm(float2 a) {
    // 1st pass
    float s = a.x + a.y;
    float e = a.y - (s - a.x);
    // 2nd pass
    float ss = s + e;
    float ee = e - (ss - s);
    return float2(ss, ee);
}

// Add hi and lo
static inline float2 sumq(float a, float b) {
    float s = a + b;
    float e = b - (s - a);
    return float2(s, e);
}

static inline float2 sumq(float2 a) {
    float s = a.x + a.y;
    float e = a.y - (s - a.x);
    return float2(s, e);
}

static inline float4 sump(float2 a_ri, float2 b_ri) {
    float2 s = a_ri + b_ri;
    float2 v = s - a_ri;
    float2 e = (a_ri - (s - v)) + (b_ri - v);
    return float4(s.x, e.x, s.y, e.y);
}

// Split two 32 bit floats into four 16 bit floats
static inline float4 split4(float2 c) {
    float2 t = c * 4097.0;
    float2 c_hi = t - (t - c);
    float2 c_lo = c - c_hi;
    return float4(c_hi.x, c_lo.x, c_hi.y, c_lo.y);
}

static inline float2 prod(float a, float b) {
    float p = a * b;
    float4 s = split4(float2(a, b));
    float e = ((s.x * s.z - p) + s.x * s.w + s.y * s.z) + s.y * s.w;
    return float2(p, e);
}

// ----------------------------------------------------------------------------
// Compare two 64 bit floating point values
// ----------------------------------------------------------------------------

// Check for zero
static inline bool isZero_f64(float2 a) {
    return all(a == 0.0);
}

// Return sign of value: -1: <0, 0: =0, 1: >0
static inline float sign_f64(float2 a) {
    if (all(a == 0.0)) {
        return 0;
    }
    else if (a.x < 0.0 || (a.x == 0.0 && a.y < 0.0)) {
        return -1;
    }
    else {
        return 1;
    }
}

// Equal
static inline bool eq(float2 a, float2 b) {
    return all(a == b);
}

// Not equal
static inline bool ne(float2 a, float2 b) {
    return any(a != b);
}

// Less than
static inline bool lt(float2 a, float2 b) {
    return (a.x < b.x || (a.x == b.x && a.y < b.y));
}

// Less than zero
static inline bool ltZero(float2 a) {
    return (a.x < 0.0 || (a.x == 0.0 && a.y < 0.0));
}

// Greater than
static inline bool gt(float2 a, float2 b) {
    return (a.x > b.x || (a.x == b.x && a.y > b.y));
}

// Greater than zero
static inline bool gtZero(float2 a) {
    return (a.x > 0.0 || (a.x == 0.0 && a.y > 0.0));
}

// Less or equal
static inline bool le(float2 a, float2 b) {
    return lt(a, b) || eq(a, b);
}

// Greater or equal
static inline bool ge(float2 a, float2 b) {
    return gt(a, b) || eq(a, b);
}


// ----------------------------------------------------------------------------
//  Real operations
// ----------------------------------------------------------------------------

// Negate
static inline float2 neg_f64(float2 a) {
    return float2(-a.x, -a.y);
}

// Add 2 64 bit floating point values
static inline float2 add_f64(float2 a, float2 b) {
    float4 st = sump(a, b);
    st.y += st.z;
    st.xy = sumq(st.xy);
    st.y += st.w;
    return sumq(st.xy);
}

// Add float to 64 bit floating point
static inline float2 add_ds(float2 a, float b) {
    float2 s = sumq(a.x, b);
    s.y += a.y;
    return sumq(s);
}

// Add float to 64 bit floating point
static inline float2 add_sd(float a, float2 b) {
    float2 s = sumq(b.x, a);
    s.y += b.y;
    return sumq(s);
}

// Subtract 2 64 bit floating point values
static inline float2 sub_f64(float2 a, float2 b) {
    return add_f64(a, -b);
}

// Subtract float from f64
static inline float2 sub_ds(float2 a, float b) {
    return add_ds(a, -b);
}

// Subtract f64 from float
static inline float2 sub_sd(float a, float2 b) {
    return -add_sd(a, b);
}

// Multiplication: f64 * f64
static inline float2 mul_f64(float2 a, float2 b) {
    float2 p = prod(a.x, b.x);
    p.y += a.x * b.y + a.y * b.x;
    return sumq(p);
}

// Multiplication: f64 * f32
static inline float2 mul_ds(float2 a, float b) {
    float2 p = prod(a.x, b);
    p.y += a.y * b;
    return sumq(p);
}

// Square of f64
static inline float2 sqr_f64(float2 a) {
    float2 p = prod(a.x, a.x);
    p.y += 2.0f * a.x * a.y;
    return sumq(p);
}

// f64 square of float
static inline float2 sqr_f64(float a) {
    return sumq(prod(a, a));
}

// Division: f64 / f64
static inline float2 div_f64(float2 a, float2 b) {
    float xn = 1.0f / b.x;
    float yn = a.x * xn;
    float2 byn = mul_ds(b, yn);
    float diff = sub_f64(a, byn).x;
    float2 p = prod(xn, diff);
    return add_f64(flt2(yn), p);
}

// Rounding
static inline float2 round_f64(float2 a) {
    float2 h = flt2(0.5f);
    if (gtZero(a)) {
        return floor_f64(add_f64(a, h));
    } else {
        return neg_f64(floor_f64(add_f64(neg_f64(a), h)));
    }
}


// ----------------------------------------------------------------------------
//  Square root, exponential, logarithm and trigonomical functions
// ----------------------------------------------------------------------------

// Square root
static inline float2 sqrt_f64(float2 a) {
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float diff = (sub_f64(a, sqr_f64(yn))).x;
    float2 p = prod(xn, diff) * 0.5f;
    return add_f64(flt2(yn), p);
}

static constant float2 F2_LN2_HI = float2(0.693147182f, 0.0f);
static constant float2 F2_LN2_LO = float2(-1.90465429995776020e-9f, 0.0f);

static float2 exp_core(float2 r) {
    float2 res = float2(7.6471636e-13f, 1.22007105e-20f);                   // 1/15!
    res = add_f64(float2(1.1470745e-11f, 2.3722077e-19f), mul_f64(r, res)); // 1/14!
    res = add_f64(float2(1.6059044e-10, -5.3525265e-18), mul_f64(r, res));  // 1/13!
    res = add_f64(float2(2.0876756e-09, 1.108284e-16),  mul_f64(r, res));   // 1/12!
    res = add_f64(float2(2.5052108e-08, 4.417623e-16),  mul_f64(r, res));
    res = add_f64(float2(2.755732e-07, -7.575112e-15),  mul_f64(r, res));
    res = add_f64(float2(2.7557319e-06, 3.7935712e-14),  mul_f64(r, res));
    res = add_f64(float2(2.4801588e-05, -3.406996e-13),  mul_f64(r, res));
    res = add_f64(float2(0.0001984127, -2.7255969e-12),  mul_f64(r, res));
    res = add_f64(float2(0.0013888889, -3.3631094e-11),  mul_f64(r, res));
    res = add_f64(float2(0.008333334, -4.346172e-10),  mul_f64(r, res));
    res = add_f64(float2(0.041666668, -1.2417635e-09),  mul_f64(r, res));
    res = add_f64(float2(0.16666667, -4.967054e-09),  mul_f64(r, res));
    res = add_f64(float2(0.5, 0.0),  mul_f64(r, res));
    res = add_f64(F2_ONE, mul_f64(r, res));  // 1 + r*(...)
    res = add_f64(F2_ONE, mul_f64(r, res));  // exp(r) = 1 + r*(1 + ...)
    
    return res;
}

static float2 exp_f64(float2 x) {
    if (gt(x, F2_EXPMAX)) return flt2(INFINITY);
    if (lt(x, F2_EXPMIN)) return F2_ZERO;

    float2 fm = round_f64(div_f64(x, F2_LOG2));
    int m = (int)fm.x;

    // Hochpräzise Argumentreduktion in zwei Schritten
    float2 r = sub_f64(x, mul_f64(fm, F2_LN2_HI));
    r = sub_f64(r,         mul_f64(fm, F2_LN2_LO));

    float2 er = exp_core(r);
    
    float scale = ldexp(1.0f, m);
    er.x *= scale;
    er.y *= scale;
    
    return er;
}

// Natural logarithm
static float2 log_f64(float2 a) {
    if (eq(a, F2_ONE)) return F2_ZERO;
    if (le(a, F2_ZERO)) return flt2(NAN);

    // Extract exponent from float32
    uint bits = as_type<uint>(a.x);
    int e = (int)((bits >> 23) & 0xFF) - 127;

    // m = a * 2^-e, exact because 2^-e is a power of 2
    float2 m = mul_f64(a, flt2(ldexp(1.0f, -e)));

    // Ensure that m in [1, 2)
    if (lt(m, F2_ONE)) { m = mul_f64(m, flt2(2.0f)); e--; }
    if (ge(m, flt2(2.0f))) { m = mul_f64(m, flt2(0.5f)); e++; }

    float2 ln_m = log_remez(m);
    return add_f64(ln_m, mul_f64(flt2((float)e), F2_LOG2));
}

static float2 log_remez(float2 m) {
    float2 t  = div_f64(sub_ds(m, 1.0f), add_ds(m, 1.0f));
    float2 t2 = mul_f64(t, t);

    // 1/23 + t²*(1/21 + t²*(1/19 + t²*1)) ...
    // Do not use a loop or lookup table! This would drop the performance.
    // Start with 1/23: error <= 1e-14
    float2 r = F2_1_23;
    r = add_f64(F2_1_21, mul_f64(t2, r));
    r = add_f64(F2_1_19, mul_f64(t2, r));
    r = add_f64(F2_1_17, mul_f64(t2, r));
    r = add_f64(F2_1_15, mul_f64(t2, r));
    r = add_f64(F2_1_13, mul_f64(t2, r));
    r = add_f64(F2_1_11, mul_f64(t2, r));
    r = add_f64(F2_1_9, mul_f64(t2, r));
    r = add_f64(F2_1_7, mul_f64(t2, r));
    r = add_f64(F2_1_5, mul_f64(t2, r));
    r = add_f64(F2_1_3, mul_f64(t2, r));
    r = add_f64(F2_ONE, mul_f64(t2, r));
    r = mul_f64(mul_ds(t, 2.0f), r);         // 2t  * (...)

    return r;
}

// Power f64, f64
// Returns NAN for a < 0
static inline float2 pow_f64(float2 a, float2 b) {
    return exp_f64(mul_f64(b, log_f64(a)));
}

// Power f64, int
static float2 pow_f64(float2 a, int b) {
    if (b == 0) return F2_ONE;
    if (b == 1) return a;
    if (b == 2) return sqr_f64(a);
    if (b == -1) return div_f64(F2_ONE, a);

    float2 r = F2_ONE;
    float2 base = a;
    int e = abs(b);

    while (e > 0) {
        if (e & 1) {
            r = mul_f64(r, base);
        }
        base = sqr_f64(base); // Square
        e >>= 1;
    }
        
    // a ^ -b = 1 / a ^ b
    return b >= 0 ? r : div_f64(F2_ONE, r);
}

// Floor
static inline float2 floor_f64(float2 a) {
    float hi = floor(a.x);
    if (hi == a.x) {
        // If high part is Integer, low part is relevant
        return sumq(hi, floor(a.y));
    }
    else {
        return sumq(hi, 0.0);
    }
}

// Floating point modulo division
static inline float2 fmod_f64(float2 a, float2 b) {
    float2 d = div_f64(a, b);
    float i = floor(d.x);
    return sub_f64(a, mul_ds(b, i));
}

// Sine
static inline float2 sin_f64(float2 a) {
    return sincos_iterate(a).xy;
}

// Cosine
static inline float2 cos_f64(float2 a) {
    return sincos_iterate(a).zw;
}

// Tangent
static inline float2 tan_f64(float2 a) {
    return tan_iterate(a);
}

// Inverse tangent
static inline float2 atan_f64(float2 a) {
    return atan2_iterate(a, F2_ONE);
}

// Inverse tangent2
static inline float2 atan2_f64(float2 y, float2 x) {
    return atan2_iterate(y, x);
}

// Inverse sine
static inline float2 asin_f64(float2 a) {
    // asin_iterate() is faster while atan2_iterate is more accurate
    return asin_iterate(a);
    // return atan2_iterate(a, sqrt_f64(sub_f64(F2_ONE, sqr_f64(a))));
}

// Inverse cosine
static inline float2 acos_f64(float2 a) {
    if(lt(a, flt2(-1)) || gt(a, F2_ONE)) return NAN;
    
    // acos_iterate() is faster while atan2_iterate is more accurate
    return acos_iterate(a);
    // return atan2_iterate(sqrt_f64(sub_f64(F2_ONE, sqr_f64(a))), a);
}

// ----------------------------------------------------------------------------
//  Complex operations
// ----------------------------------------------------------------------------

// Add 2 64 bit complex values
static inline float4 add_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, b.xy), add_f64(a.zw, b.zw));
}

// Subtract 2 64 bit complex values
static inline float4 sub_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, -b.xy), add_f64(a.zw, -b.zw));
}

// Multiply 2 64 bit complex values
static inline float4 mul_c64(float4 a, float4 b) {
    float2 r1 = mul_f64(a.xy, b.xy);    // a.r * b.r
    float2 r2 = mul_f64(a.zw, b.zw);    // a.i * b.i
    float2 i1 = mul_f64(a.xy, b.zw);    // a.r * b.i
    float2 i2 = mul_f64(a.zw, b.xy);    // a.i * b.r
    return float4(sub_f64(r1, r2), add_f64(i1, i2));
}

// Square of 64 bit complex value
static inline float4 sqr_c64(float4 a) {
    float2 r1 = mul_f64(a.xy, a.xy);
    float2 r2 = mul_f64(a.zw, a.zw);
    float2 i1 = mul_f64(a.xy, a.zw);
    return float4(sub_f64(r1, r2), add_f64(i1, i1));
}

// Divide 2 64 bit complex values
static inline float4 div_c64(float4 a, float4 b) {
    float2 d = add_f64(mul_f64(b.xy, b.xy), mul_f64(b.zw, b.zw));
    float2 r = div_f64(add_f64(mul_f64(a.xy, b.xy), mul_f64(a.zw, b.zw)), d);
    float2 i = div_f64(sub_f64(mul_f64(a.zw, b.xy), mul_f64(a.xy, b.zw)), d);
    return float4(r, i);
}

// 64 bit complex square root
static inline float4 sqrt_c64(float4 a) {
    float2 dc = abs_c64(a);
    float2 r = sqrt_f64(mul_ds(add_f64(dc, a.xy), 0.5));
    float2 i = lt(a.zw, F2_ZERO) ? -sqrt_f64(mul_ds(sub_f64(dc, a.xy), 0.5)) : sqrt_f64(mul_ds(sub_f64(dc, a.xy), 0.5));
    return float4(r, i);
}

// 64 bit complex exponential function
static inline float4 exp_c64(float4 a) {
    float2 e = exp_f64(a.xy);
    return float4(mul_f64(e, cos_f64(a.zw)), mul_f64(e, sin_f64(a.zw)));
}

// Compare 64 bit complex values
static inline bool eq(float4 a, float4 b) {
    return all(a == b);
}

static inline bool ne(float4 a, float4 b) {
    return any(a != b);
}

static inline float2 norm_c64(float4 c) {
    return add_f64(sqr_f64(c.xy), sqr_f64(c.zw));
}

static inline float2 abs_c64(float4 c) {
    return sqrt_f64(norm_c64(c));
}


#endif


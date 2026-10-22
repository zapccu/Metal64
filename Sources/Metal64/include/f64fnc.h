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

#pragma once
#include "f64pragma.h"

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
static constant float2 F2_EXPMAX = float2(88.02969f,  -1.6724026e-06f);  // 127 * ln(2)
static constant float2 F2_EXPMIN = float2(-87.33655f,  3.1010095e-06f);  // -126 * ln(2)


//
//  Declare functions
//
static float4 sincos_f64(float2);
static float4 sincos_iterate(float2);
static float2 tan_iterate(float2);              // no longer used
static float2 asin_iterate(float2);             // no longer used
static float2 acos_iterate(float2);             // no longer used
static float2 atan2_iterate(float2, float2);
static float2 exp_iterate(float2);              // no longer used
static float2 log_iterate(float2);              // no longer used
static inline float2 flt2(float);
static inline float2 floor_f64(float2);
static inline float2 abs_c64(float4);


//
//  Helper functions
//

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

// Add hi and lo (Fast-Two-Sum)
// Precondition: |a| >= |b| (or a == 0). Use two_sum() if the order is unknown.
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

// Error-free sum of two floats without precondition on magnitudes (Knuth Two-Sum)
static inline float2 two_sum(float a, float b) {
    float s = a + b;
    float v = s - a;
    float e = (a - (s - v)) + (b - v);
    return float2(s, e);
}

static inline float4 sump(float2 a_ri, float2 b_ri) {
    float2 s = a_ri + b_ri;
    float2 v = s - a_ri;
    float2 e = (a_ri - (s - v)) + (b_ri - v);
    return float4(s.x, e.x, s.y, e.y);
}

// Error-free product of two floats (Two-Product): a * b = p + e exactly.
// Metal's fma() is correctly rounded, so fma(a, b, -p) yields the exact rounding error.
// This replaces the Veltkamp/Dekker split (c * 4097), which needs ~17 operations
// and overflows for |a|, |b| > ~8e34, producing NaN.
static inline float2 prod(float a, float b) {
    float p = a * b;
    float e = fma(a, b, -p);
    return float2(p, e);
}

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


//
//  Real operations
//

// Negate
static inline float2 neg_f64(float2 a) {
    return float2(-a.x, -a.y);
}

// Absolute value
// abs() on float2 works component wise and must not be used
static inline float2 abs_f64(float2 a) {
    return ltZero(a) ? neg_f64(a) : a;
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
    float2 s = two_sum(a.x, b);
    s.y += a.y;
    return sumq(s);
}

// Add float to 64 bit floating point
static inline float2 add_sd(float a, float2 b) {
    float2 s = two_sum(b.x, a);
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
    return add_sd(a, -b);
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

// Division: f64 / f32
static inline float2 div_ds(float2 a, float b) {
    float q1   = a.x / b;
    float2 p   = prod(q1, b);                 // exact
    float s    = ((a.x - p.x) - p.y) + a.y;   // rest
    float q2   = s / b;
    float hi   = q1 + q2;                     // quick_two_sum
    return float2(hi, q2 - (hi - q1));
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
    // rsqrt(0) = inf and 0 * inf = NaN, so handle 0 and negative values first
    if (a.x <= 0.0f) {
        return a.x == 0.0f ? F2_ZERO : float2(NAN, NAN);
    }
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float diff = (sub_f64(a, sqr_f64(yn))).x;
    float2 p = prod(xn, diff) * 0.5f;
    return add_f64(flt2(yn), p);
}

// Constants for argument reduction (Cody-Waite).
// A constant c is split into 3 floats c = A + B + C (~72 bit). k * A and k * B are
// computed exactly with prod(), so x - k * c stays accurate even if x and k * c cancel.
static constant float F_PI_2_A  =  1.5707964e+00f;   // pi / 2
static constant float F_PI_2_B  = -4.371139e-08f;
static constant float F_PI_2_C  = -1.7151245e-15f;
static constant float F_2_PI    =  6.3661975e-01f;   // 2 / pi (float is sufficient for k)
static constant float F_LN2_A   =  6.931472e-01f;    // ln(2)
static constant float F_LN2_B   = -1.9046542e-09f;
static constant float F_LN2_C   = -8.783184e-17f;
static constant float F_1_LN2   =  1.442695e+00f;    // 1 / ln(2) (float is sufficient for k)
static constant float F_SQRT2   =  1.4142135e+00f;   // sqrt(2), only used as threshold

// Return x - k * (A + B + C) with high precision, k must be an integer value
static inline float2 reduce_arg(float2 x, float k, float a, float b, float c) {
    float2 r = sub_f64(x, prod(k, a));
    r = sub_f64(r, prod(k, b));
    return sub_ds(r, k * c);
}

// exp(r) for |r| <= ln(2) / 2 (Taylor polynomial, degree 13).
// Terms from r^9 on contribute < 1e-9 * exp(r), so they are evaluated in float:
// their rounding error stays below 1e-16 relative to the result.
static inline float2 exp_core(float2 r) {
    float rf = r.x;
    float t = 1.6059044e-10f;                    // 1/13!
    t = fma(rf, t, 2.0876756e-09f);              // 1/12!
    t = fma(rf, t, 2.5052108e-08f);              // 1/11!
    t = fma(rf, t, 2.755732e-07f);               // 1/10!
    t = fma(rf, t, 2.7557319e-06f);              // 1/9!

    float2 p = add_f64(float2(2.4801588e-05f, -3.406996e-13f), mul_ds(r, t));    // 1/8!
    p = add_f64(float2(1.984127e-04f,  -2.7255969e-12f), mul_f64(r, p));         // 1/7!
    p = add_f64(float2(1.3888889e-03f, -3.3631094e-11f), mul_f64(r, p));         // 1/6!
    p = add_f64(float2(8.333334e-03f,  -4.346172e-10f),  mul_f64(r, p));         // 1/5!
    p = add_f64(float2(4.1666668e-02f, -1.2417635e-09f), mul_f64(r, p));         // 1/4!
    p = add_f64(float2(1.6666667e-01f, -4.967054e-09f),  mul_f64(r, p));         // 1/3!
    p = add_ds(mul_f64(r, p), 0.5f);                                             // 1/2!
    p = add_ds(mul_f64(r, p), 1.0f);                                             // 1/1!
    return add_ds(mul_f64(r, p), 1.0f);                                          // 1/0!
}

// Exponential function
// x = m * ln(2) + r, |r| <= ln(2) / 2  =>  exp(x) = 2^m * exp(r)
static float2 exp_f64(float2 x) {
    if (isnan(x.x)) return x;
    if (gt(x, F2_EXPMAX)) return float2(INFINITY, 0.0f);
    if (lt(x, F2_EXPMIN)) return F2_ZERO;

    float m = rint(x.x * F_1_LN2);
    float2 er = exp_core(reduce_arg(x, m, F_LN2_A, F_LN2_B, F_LN2_C));

    // Multiplication by 2^m is exact
    int im = int(m);
    return float2(ldexp(er.x, im), ldexp(er.y, im));
}

// ln(m) for m in [sqrt(1/2), sqrt(2)):
// ln(m) = 2 * atanh(t) = 2t * (1 + t^2/3 + t^4/5 + ...), t = (m - 1) / (m + 1), |t| <= 0.172
// Terms from t^12 on contribute < 1e-10, so they are evaluated in float.
static inline float2 log_series(float2 m) {
    float2 t  = div_f64(sub_ds(m, 1.0f), add_ds(m, 1.0f));
    float2 t2 = sqr_f64(t);
    float tf = t2.x;

    float s = 5.263158e-02f;                     // 1/19
    s = fma(tf, s, 5.882353e-02f);               // 1/17
    s = fma(tf, s, 6.666667e-02f);               // 1/15
    s = fma(tf, s, 7.692308e-02f);               // 1/13

    float2 r = add_f64(F2_1_11, mul_ds(t2, s));
    r = add_f64(F2_1_9, mul_f64(t2, r));
    r = add_f64(F2_1_7, mul_f64(t2, r));
    r = add_f64(F2_1_5, mul_f64(t2, r));
    r = add_f64(F2_1_3, mul_f64(t2, r));
    r = add_ds(mul_f64(t2, r), 1.0f);
    return mul_f64(t * 2.0f, r);                 // t * 2 is exact
}

// Natural logarithm
// a = 2^e * m, m in [sqrt(1/2), sqrt(2))  =>  ln(a) = e * ln(2) + ln(m)
static float2 log_f64(float2 a) {
    if (isnan(a.x)) return a;
    if (eq(a, F2_ONE)) return F2_ZERO;
    if (le(a, F2_ZERO)) return float2(NAN, NAN);
    if (isinf(a.x)) return a;

    // Extract exponent from float32, scaling by 2^-e is exact
    uint bits = as_type<uint>(a.x);
    int e = (int)((bits >> 23) & 0xFF) - 127;
    float2 m = float2(ldexp(a.x, -e), ldexp(a.y, -e));   // m in [1, 2)

    if (m.x > F_SQRT2) {
        m = m * 0.5f;
        e++;
    }

    float2 ln_m = log_series(m);
    if (e == 0) return ln_m;

    // e * ln(2) with 3 part constant, prod() is exact
    float fe = float(e);
    float2 eln2 = add_f64(prod(fe, F_LN2_A), prod(fe, F_LN2_B));
    eln2 = add_ds(eln2, fe * F_LN2_C);
    return add_f64(eln2, ln_m);
}

// Power f64, f64
// Returns NAN for a < 0
static inline float2 pow_f64(float2 a, float2 b) {
    return exp_f64(mul_f64(b, log_f64(a)));
}

// Sine and cosine
// x = k * pi/2 + r, |r| <= pi/4. sin(r) and cos(r) are computed with Taylor polynomials,
// the quadrant k mod 4 selects the result.
// Returns float4(sin(x), cos(x)) like sincos_iterate()
static float4 sincos_f64(float2 x) {
    if (!isfinite(x.x)) return float4(NAN, NAN, NAN, NAN);

    // Above 2^20 * pi/2 the 72 bit constant isn't precise enough, fall back to CORDIC
    if (fabs(x.x) > 1.6e6f) return sincos_iterate(x);

    float k = rint(x.x * F_2_PI);
    float2 r  = reduce_arg(x, k, F_PI_2_A, F_PI_2_B, F_PI_2_C);
    float2 r2 = sqr_f64(r);
    float rf = r2.x;

    // sin(r) = r + r^3 * (-1/3! + r^2/5! - ...), terms from r^13 on in float
    float ts = 2.8114574e-15f;                   //  1/17!
    ts = fma(rf, ts, -7.6471636e-13f);           // -1/15!
    ts = fma(rf, ts,  1.6059044e-10f);           //  1/13!
    float2 s = add_f64(float2(-2.5052108e-08f, -4.417623e-16f), mul_ds(r2, ts));   // -1/11!
    s = add_f64(float2( 2.7557319e-06f,  3.7935712e-14f), mul_f64(r2, s));         //  1/9!
    s = add_f64(float2(-1.984127e-04f,   2.7255969e-12f), mul_f64(r2, s));         // -1/7!
    s = add_f64(float2( 8.333334e-03f,  -4.346172e-10f),  mul_f64(r2, s));         //  1/5!
    s = add_f64(float2(-1.6666667e-01f,  4.967054e-09f),  mul_f64(r2, s));         // -1/3!
    s = add_f64(r, mul_f64(mul_f64(r, r2), s));

    // cos(r) = 1 + r^2 * (-1/2! + r^2/4! - ...), terms from r^12 on in float
    float tc = 4.7794773e-14f;                   //  1/16!
    tc = fma(rf, tc, -1.1470745e-11f);           // -1/14!
    tc = fma(rf, tc,  2.0876756e-09f);           //  1/12!
    float2 c = add_f64(float2(-2.755732e-07f,  7.575112e-15f), mul_ds(r2, tc));    // -1/10!
    c = add_f64(float2( 2.4801588e-05f, -3.406996e-13f), mul_f64(r2, c));          //  1/8!
    c = add_f64(float2(-1.3888889e-03f,  3.3631094e-11f), mul_f64(r2, c));         // -1/6!
    c = add_f64(float2( 4.1666668e-02f, -1.2417635e-09f), mul_f64(r2, c));         //  1/4!
    c = add_ds(mul_f64(r2, c), -0.5f);                                             // -1/2!
    c = add_ds(mul_f64(r2, c), 1.0f);

    switch (int(k) & 3) {
        case 0:  return float4(s, c);
        case 1:  return float4(c, neg_f64(s));
        case 2:  return float4(neg_f64(s), neg_f64(c));
        default: return float4(neg_f64(c), s);
    }
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
// Floor based like Python's %: result has the sign of b (C fmod truncates instead)
static inline float2 fmod_f64(float2 a, float2 b) {
    float2 i = floor_f64(div_f64(a, b));
    float2 r = sub_f64(a, mul_f64(b, i));
    // Correct off-by-one quotients caused by rounding of the division
    if (gtZero(b)) {
        if (ltZero(r))  r = add_f64(r, b);
        else if (ge(r, b)) r = sub_f64(r, b);
    }
    else {
        if (gtZero(r))  r = add_f64(r, b);
        else if (le(r, b)) r = sub_f64(r, b);
    }
    return r;
}

// Sine
static inline float2 sin_f64(float2 a) {
    return sincos_f64(a).xy;
}

// Cosine
static inline float2 cos_f64(float2 a) {
    return sincos_f64(a).zw;
}

// Tangent
static inline float2 tan_f64(float2 a) {
    float4 sc = sincos_f64(a);
    return div_f64(sc.xy, sc.zw);
}

// Lookup table atan(k / 8), k = 0..8
static constant float2 atan_table[9] = {
    float2(0.0f,            0.0f),              // atan(0/8)
    float2(1.24354996e-01f, -1.2403822e-09f),   // atan(1/8)
    float2(2.4497867e-01f,  -3.1786778e-09f),   // atan(2/8)
    float2(3.5877067e-01f,   1.7639499e-09f),   // atan(3/8)
    float2(4.636476e-01f,    5.0121587e-09f),   // atan(4/8)
    float2(5.585993e-01f,    2.2111598e-08f),   // atan(5/8)
    float2(6.435011e-01f,    5.8689373e-09f),   // atan(6/8)
    float2(7.1883e-01f,      1.01883355e-08f),  // atan(7/8)
    float2(7.853982e-01f,   -2.1855694e-08f)    // atan(8/8) = pi/4
};

// atan(z) for 0 <= z <= 1
// With c = k/8 closest to z: atan(z) = atan(c) + atan(t), t = (z - c) / (1 + z * c), |t| <= 1/16.
// atan(t) = t - t^3/3 + t^5/5 - ... up to t^13, terms from t^9 on contribute < 3e-11
// relative and are evaluated in float.
static inline float2 atan_core(float2 z) {
    int k = min(int(rint(z.x * 8.0f)), 8);
    float c = float(k) * 0.125f;
    float2 t  = div_f64(sub_ds(z, c), add_ds(mul_ds(z, c), 1.0f));
    float2 t2 = sqr_f64(t);
    float tf = t2.x;

    float p = 7.692308e-02f;                     //  1/13
    p = fma(tf, p, -9.090909e-02f);              // -1/11
    p = fma(tf, p,  1.1111111e-01f);             //  1/9
    float2 s = add_f64(neg_f64(F2_1_7), mul_ds(t2, p));
    s = add_f64(F2_1_5, mul_f64(t2, s));
    s = add_f64(neg_f64(F2_1_3), mul_f64(t2, s));
    float2 at = add_f64(t, mul_f64(mul_f64(t, t2), s));   // t + t^3 * (...)

    return add_f64(atan_table[k], at);
}

// Inverse tangent2, result in [-pi, pi]
// The ratio of the smaller and the larger absolute value is reduced to [0, 1]:
// |y| <= |x|: atan(|y| / |x|), otherwise pi/2 - atan(|x| / |y|). Then the quadrant is restored.
static inline float2 atan2_f64(float2 y, float2 x) {
    if (isnan(x.x) || isnan(y.x)) return float2(NAN, NAN);
    float2 ax = abs_f64(x);
    float2 ay = abs_f64(y);
    if (isZero_f64(ax) && isZero_f64(ay)) return F2_ZERO;

    float2 r;
    if (isinf(ax.x) || isinf(ay.x)) {
        if (isinf(ax.x) && isinf(ay.x)) r = F2_PI * 0.25f;   // * 0.25 is exact
        else r = isinf(ax.x) ? F2_ZERO : F2_PI_2;
    }
    else if (le(ay, ax)) {
        r = atan_core(div_f64(ay, ax));
    }
    else {
        // pi/2 - atan(z) with 3 part constant
        r = sub_f64(float2(F_PI_2_A, F_PI_2_B), atan_core(div_f64(ax, ay)));
        r = add_ds(r, F_PI_2_C);
    }

    if (ltZero(x)) {
        // pi - r with 3 part constant, * 2 is exact
        r = sub_f64(float2(2.0f * F_PI_2_A, 2.0f * F_PI_2_B), r);
        r = add_ds(r, 2.0f * F_PI_2_C);
    }
    return ltZero(y) ? neg_f64(r) : r;
}

// Inverse tangent
static inline float2 atan_f64(float2 a) {
    return atan2_f64(a, F2_ONE);
}

// sqrt(1 - a^2) computed as sqrt((1 - a) * (1 + a)) to avoid cancellation near |a| = 1
static inline float2 sqrt_1_minus_sqr(float2 a) {
    return sqrt_f64(mul_f64(sub_sd(1.0f, a), add_sd(1.0f, a)));
}

// Inverse sine
// asin(a) = atan2(a, sqrt(1 - a^2))
static inline float2 asin_f64(float2 a) {
    if (gt(abs_f64(a), F2_ONE)) return float2(NAN, NAN);
    return atan2_f64(a, sqrt_1_minus_sqr(a));
}

// Inverse cosine
// acos(a) = atan2(sqrt(1 - a^2), a)
static inline float2 acos_f64(float2 a) {
    if (gt(abs_f64(a), F2_ONE)) return float2(NAN, NAN);
    return atan2_f64(sqrt_1_minus_sqr(a), a);
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
    float2 r1 = sqr_f64(a.xy);
    float2 r2 = sqr_f64(a.zw);
    float2 i1 = mul_f64(a.xy, a.zw);
    return float4(sub_f64(r1, r2), i1 * 2.0f);   // * 2 is exact
}

// Divide 2 64 bit complex values
static inline float4 div_c64(float4 a, float4 b) {
    float2 d = add_f64(mul_f64(b.xy, b.xy), mul_f64(b.zw, b.zw));
    float2 r = div_f64(add_f64(mul_f64(a.xy, b.xy), mul_f64(a.zw, b.zw)), d);
    float2 i = div_f64(sub_f64(mul_f64(a.zw, b.xy), mul_f64(a.xy, b.zw)), d);
    return float4(r, i);
}

// 64 bit complex square root
// t = sqrt((|z| + |x|) / 2) avoids the cancellation of |z| - x, the other part is y / (2t).
// Needs only one square root.
static inline float4 sqrt_c64(float4 a) {
    if (isZero_f64(a.xy) && isZero_f64(a.zw)) return float4(0.0f);
    float2 t = sqrt_f64(add_f64(abs_c64(a), abs_f64(a.xy)) * 0.5f);   // * 0.5 is exact
    float2 u = div_f64(a.zw, t * 2.0f);                                 // y / (2t)
    if (!ltZero(a.xy)) {
        return float4(t, u);
    }
    return float4(abs_f64(u), ltZero(a.zw) ? neg_f64(t) : t);
}

// 64 bit complex exponential function
static inline float4 exp_c64(float4 a) {
    float2 e = exp_f64(a.xy);
    float4 sc = sincos_f64(a.zw);       // .xy = sin, .zw = cos, computed only once
    return float4(mul_f64(e, sc.zw), mul_f64(e, sc.xy));
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


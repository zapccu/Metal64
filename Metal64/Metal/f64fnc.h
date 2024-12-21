//
//  f64fnc.h
//
//  Functions for 64 bit floating point GPU/Metal calculations
//
//  Created by Dirk Braner on 13.12.24.
//
//  64 bit real float:
//
//    A 64 bit float value is represented by float2 data type.
//    The corresponding Swift data type is SIMD2<Float32>.
//      .x = Hight value part
//      .y = Low value part
//
//  64 bit complex float:
//
//    A 64 bit complex value is represented by float4 data type.
//    The corresponding Swift data type is SIMD4<Float32>.
//      .xy = float2 with real part high, low
//      .zw = float2 with imaginary part high, low
//

#ifndef __F64FNC_H
#define __F64FNC_H

using namespace metal;

// ----------------------------------------------------------------------------
//  Constants
// ----------------------------------------------------------------------------

constant float2 pi_f2   = float2(3.1415927, -8.742278e-08);
constant float2 pi2_f2  = float2(1.5707964, -4.371139e-08);
constant float2 log2_f2 = float2(0.6931472, -1.9046542e-09);

// ----------------------------------------------------------------------------
//  Helper functions
// ----------------------------------------------------------------------------

// Add hi and lo
float2 sumq(float a, float b) {
    float s = a + b;
    float e = b - (s - a);
    return float2(s, e);
}

float4 sump(float2 a_ri, float2 b_ri) {
    float2 s = a_ri + b_ri;
    float2 v = s - a_ri;
    float2 e = (a_ri - (s - v)) + (b_ri - v);
    return float4(s.x, e.x, s.y, e.y);
}

// Split two 32 bit floats into four 16 bit floats
float4 split4(float2 c) {
    const float split = 4097;
    float2 t = c * split;
    float2 c_hi = t - (t - c);
    float2 c_lo = c - c_hi;
    return float4(c_hi.x, c_lo.x, c_hi.y, c_lo.y);
}

float2 prod(float a, float b) {
    float p = a * b;
    float4 s = split4(float2(a, b));
    float e = ((s.x * s.z - p) + s.x * s.w + s.y * s.z) + s.y * s.w;
    return float2(p, e);
}

// ----------------------------------------------------------------------------
//  Real operations
// ----------------------------------------------------------------------------

// Add 2 64 bit floating point values
float2 add_f64(float2 a, float2 b) {
    float4 st;
    st = sump(a, b);
    st.y += st.z;
    st.xy = sumq(st.x, st.y);
    st.y += st.w;
    st.xy = sumq(st.x, st.y);
    return st.xy;
}

// Subtract 2 64 bit floating point values
float2 sub_f64(float2 a, float2 b) {
    return add_f64(a, -b);
}

// Multiplication: f64 * f64
float2 mul_f64(float2 a, float2 b) {
    float2 p = prod(a.x, b.x);
    p.y += a.x * b.y;
    p.y += a.y * b.x;
    p = sumq(p.x, p.y);
    return p;
}

// Square of f64
float2 sqr_f64(float2 a) {
    float2 p = prod(a.x, a.x);
    p.y += 2.0f * a.x * a.y;
    p = sumq(p.x, p.y);
    return p;
}

// Multiplication: f64 * f32
float2 mulds(float2 a, float b) {
    float2 p = prod(a.x, b);
    p.y += a.y * b;
    p = sumq(p.x, p.y);
    return p;
}

// Division: f64 / f64
float2 div_f64(float2 b, float2 a) {
    float xn = 1.0f / a.x;
    float yn = b.x * xn;
    float2 ayn = mulds(a, yn);
    float diff = sub_f64(b, ayn).x;
    float2 p = prod(xn, diff);
    return add_f64(float2(yn, 0.0), p);
}

// ----------------------------------------------------------------------------
// Compare two 64 bit floating point values
// ----------------------------------------------------------------------------

// Check for zero
bool isZero(float2 a) {
    return a.x == 0.0 && a.y == 0.0;
}

// Equal
bool eq(float2 a, float2 b) {
    return all(a == b);
}

// Not equal
bool ne(float2 a, float2 b) {
    return any(a != b);
}

// Less than
bool lt(float2 a, float2 b) {
    return (a.x < b.x || (a.x == b.x && a.y < b.y));
}

// Greater than
bool gt(float2 a, float2 b) {
    return (a.x > b.x || (a.x == b.x && a.y > b.y));
}

// Less or equal
bool le(float2 a, float2 b) {
    return lt(a, b) || eq(a, b);
}

// Greater or equal
bool ge(float2 a, float2 b) {
    return gt(a, b) || eq(a, b);
}

// ----------------------------------------------------------------------------
//  Square root, exponential, logarithm and trigonomical functions
// ----------------------------------------------------------------------------

// Square root
float2 sqrt_f64(float2 a) {
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float2 ynsqr = sqr_f64(float2(yn, 0.0f));
    float diff = (sub_f64(a, ynsqr)).x;
    float2 p = prod(xn, diff) / 2.0f;
    return add_f64(float2(yn, 0.0f), p);
}

// Exponential. Returns NAN if a > 1.0
/*
float2 exp_f64(float2 a) {
    float thresh = 1.0e-20;
    float2 t, p, s;
    float2 f = float2(2.0f, 0.0f);      // denominator
    float m = 2.0f;
    
    // Calculate first 3 steps of Taylor series: 1 + x + x^2 / 2
    s = add_f64(float2(1.0f, 0.0f), a); // 1 + x
    p = sqr_f64(a);                     // x^2
    t = p / 2.0f;                       // x^2 / 2
    
    while (abs(t.x) > thresh) {
        s = add_f64(s, t);              // Current sum
        p = mul_f64(p, a);              // x^n
        m += 1.0f;
        f = mul_f64(f, float2(m, 0.0f));
        t = div_f64(p, f);
    }
    
    return add_f64(s, t);
}
*/

// Exponential
float2 exp_f64(float2 a) {
    float2 s = add_f64(a, float2(1.0f, 0.0f));
    float2 t = a;
    float2 d = a;
    int m = 2;
    
    while (abs(t.x) > 1e-20) {
        d = div_f64(a, float2(m, 0.0f));
        t = mul_f64(t, d);
        s = add_f64(s, t);
        m++;
    }

    return s;
}

// Natural logarithm
float2 log_f64(float2 a) {
    float2 xi = float2(0.0f, 0.0f);
    
    if(ne(a, float2(1.0f, 0.0f))) {
        if (le(a, float2(0.0f, 0.0f))) {
            xi = log(a.x);  // log not defined, return NaN
        }
        else {
            xi.x = log(a.x);
            xi = add_f64(add_f64(xi, mul_f64(exp_f64(-xi), a)), float2(-1.0f, 0.0f));
        }
    }
    
    return xi;
}

// Power f64, f64
float2 pow_f64(float2 a, float2 b) {
    return exp_f64(mul_f64(b, log_f64(a)));
}

// Power f64, int
float2 pow_f64(float2 a, int b) {
    float2 r = float2(1.0f, 0.0f);
    int i;
    
    for (i=0; i<b; i++) {
        r = mul_f64(r, a);
    }
    
    return r;
}

// Sinus/Cosinus
float4 sincos_f64(float2 a) {
    const float thresh = 1.0e-20 * abs(a.x) * 1.0f;
    float2 t;
    float2 p = a;
    float2 s = a;
    float2 x = -sqrt_f64(a);
    float2 f = float2(1.0f, 0.0f);
    float m = 1.0f;
    float2 sin_a, cos_a;
    
    if (a.x == 0.0f) return float4(0.0f, 0.0f, 1.0f, 0.0f);

    while(1) {
        p = mul_f64(p, x);
        m += 2.0f;
        f = mul_f64(f, float2((m * (m - 1.0f)), 0.0f));
        t = div_f64(p, f);
        s = add_f64(s, t);
        if (abs(t.x) < thresh) break;
    }
    
    sin_a = s;
    cos_a = sqrt_f64(add_f64(float2(1.0f, 0.0f), -sqrt_f64(s)));
    
    return float4(sin_a, cos_a);
}

// Sine
float2 sin_f64(float2 a) {
    return sincos_f64(a).xy;
}

// Cosine
float2 cos_f64(float2 a) {
    return sincos_f64(a).zw;
}

// Tangent
float2 tan_f64(float2 a) {
    float4 sc = sincos_f64(a);
    return div_f64(sc.xy, sc.zw);
}

// Arc tangent iteration
float2 atan_iterate(float2 a, int n) {
    float2 a2 = mul_f64(a, a);
    float2 d = float2(n * 2 + 1, 0.0);
    float2 f;
    int k;
    float2 k2;
    
    for (k=n; k>0; k--) {
        f = float2(k * 2 - 1, 0.0f);
        k2 = float2(k * k);
        d = add_f64(f, div_f64(mul_f64(k2, a2), d));
    }
    
    return div_f64(a, d);
}

// Inverse tangent
float2 atan_f64(float2 a) {
    if (eq(a, float2(0.0f, 0.0f))) {
        return float2(0.0f, 0.0f);
    }
    else if (gt(a, float2(1.0f, 0.0f))) {
        return sub_f64(pi2_f2, atan_iterate(div_f64(float2(1.0f, 0.0f), a), 21));
    }
    else {
        return atan_iterate(a, 21);
    }
}

// Inverse tangent2
float2 atan2_f64(float2 y, float2 x) {
    if (gt(x, float2(0.0f, 0.0f))) {
        return atan_f64(div_f64(y, x));
    }
    else if (lt(x, float2(0.0f, 0.0f)) && ge(y, float2(0.0f, 0.0f))) {
        return add_f64(atan_f64(div_f64(y, x)), pi_f2);
    }
    else if (isZero(x) && lt(y, float2(0.0f, 0.0f))) {
        return sub_f64(atan_f64(div_f64(y, x)), pi_f2);
    }
    else if (isZero(x) && gt(y, float2(0.0f, 0.0f))) {
        return pi2_f2;
    }
    else if (isZero(x) && lt(y, float2(0.0f, 0.0f))) {
        return -pi2_f2;
    }
    else {
        return NAN;
    }
}

// Inverse sine
float2 asin_f64(float2 a) {
    float2 d = sqrt_f64(sub_f64(float2(1.0f, 0.0f), mul_f64(a, a)));
    return atan_f64(div_f64(a, d));
}

// Inverse cosine
float2 acos_f64(float2 a) {
    float2 d = sqrt_f64(sub_f64(float2(1.0f, 0.0f), mul_f64(a, a)));
    return sub_f64(pi2_f2, atan_f64(div_f64(a, d)));
}

// ----------------------------------------------------------------------------
//  Complex operations
// ----------------------------------------------------------------------------

// Add 2 64 bit complex values
float4 add_c64(float4 a, float4 b) {
    float2 r = add_f64(a.xy, b.xy);
    float2 i = add_f64(a.zw, b.zw);
    return float4(r.x, r.y, i.x, i.y);
}

// Subtract 2 64 bit complex values
float4 sub_c64(float4 a, float4 b) {
    float2 r = add_f64(a.xy, -b.xy);
    float2 i = add_f64(a.zw, -b.zw);
    return float4(r.x, r.y, i.x, i.y);
}

// Multiply 2 64 bit complex values
float4 mul_c64(float4 a, float4 b) {
    float2 r1 = mul_f64(a.xy, b.xy);    // a.r * b.r
    float2 r2 = mul_f64(a.zw, b.zw);    // a.i * b.i
    float2 i1 = mul_f64(a.xy, b.zw);    // a.r * b.i
    float2 i2 = mul_f64(a.zw, b.xy);    // a.i * b.r
    float2 r = sub_f64(r1, r2);
    float2 i = add_f64(i1, i2);
    return float4(r.x, r.y, i.x, i.y);
}

// Divide 2 64 bit complex values
float4 div_c64(float4 a, float4 b) {
    float2 d = add_f64(mul_f64(b.xy, b.xy), mul_f64(b.zw, b.zw));
    float2 r = div_f64(add_f64(mul_f64(a.xy, b.xy), mul_f64(a.zw, b.zw)), d);
    float2 i = div_f64(sub_f64(mul_f64(a.zw, b.xy), mul_f64(a.xy, b.zw)), d);
    return float4(r.x, r.y, i.x, i.y);
}

float2 norm_c64(float4 c) {
    float2 a = mul_f64(c.xy, c.xy);
    float2 b = mul_f64(c.zw, c.zw);
    return add_f64(a, b);
}

float2 abs_c64(float4 c) {
    return sqrt_f64(norm_c64(c));
}

#endif


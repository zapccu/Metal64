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
    float yn = a.x * xn;
    float2 ayn = mulds(a, yn);
    float diff = sub_f64(b, ayn).x;
    float2 p = prod(xn, diff);
    return add_f64(float2(yn, 0.0), p);
}

// Square root
float2 sqrt_f64(float2 a) {
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float2 ynsqr = sqrt(yn);
    float diff = (sub_f64(a, ynsqr)).x;
    float2 p = prod(xn, diff) / 2;
    return add_f64(yn, p);
}

// ----------------------------------------------------------------------------
// Compare two 64 bit floating point values
// ----------------------------------------------------------------------------

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

float2 norm_c64(float4 c) {
    float2 a = mul_f64(c.xy, c.xy);
    float2 b = mul_f64(c.zw, c.zw);
    return add_f64(a, b);
}

float2 abs_c64(float4 c) {
    return sqrt_f64(norm_c64(c));
}

#endif


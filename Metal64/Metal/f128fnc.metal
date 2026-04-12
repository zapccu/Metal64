//
//  f128fnc.metal
//  Metal64
//
//  Created by Dirk Braner on 12.02.26.
//
// Experimental code for implementing 128 bit floating point numbers
// Currently only +, -, * are supported.

#include <metal_stdlib>
using namespace metal;

// Calculate s = a + b and error e
inline float2 two_sum(float a, float b) {
    float s = a + b;
    float v = s - a;
    float e = (a - (s - v)) + (b - v);
    return float2(s, e);
}

// Quick version of two_sum if |a| >= |b|
inline float2 quick_two_sum(float a, float b) {
    float s = a + b;
    float e = b - (s - a);
    return float2(s, e);
}

float4 qf_add(float4 a, float4 b) {
    float2 s;
    float4 r;

    s = two_sum(a.x, b.x);
    r.x = s.x;
    
    s = two_sum(a.y, b.y + s.y);
    r.y = s.x;
    
    s = two_sum(a.z, b.z + s.y);
    r.z = s.x;
    
    r.w = a.w + b.w + s.y;
    
    s = quick_two_sum(r.x, r.y);
    r.x = s.x;
    s = quick_two_sum(s.y, r.z);
    r.y = s.x;
    s = quick_two_sum(s.y, r.w);
    r.z = s.x;
    r.w = s.y;

    return r;
}

float4 qf_sub(float4 a, float4 b) {
    return qf_add(a, b * -1.0f);
}

// Split float into 2 parts
inline float2 split(float a) {
    float t = a * ((1 << 12) + 1);
    float a_hi = t - (t - a);
    float a_lo = a - a_hi;
    return float2(a_hi, a_lo);
}

// Exact multiplication of 2 floats
inline float2 two_prod(float a, float b) {
    float x = a * b;
    float2 a_s = split(a);
    float2 b_s = split(b);
    float err = ((a_s.x * b_s.x - x) + a_s.x * b_s.y + a_s.y * b_s.x) + a_s.y * b_s.y;
    return float2(x, err);
}

float4 qf_mul(float4 a, float4 b) {
    float2 p;

    p = two_prod(a.x, b.x);
    float4 r = float4(p.x, p.y, 0.0, 0.0);

    p = two_prod(a.x, b.y);
    r = qf_add(r, float4(0, p.x, p.y, 0));
    
    p = two_prod(a.y, b.x);
    r = qf_add(r, float4(0, p.x, p.y, 0));

    return r;
}

float4 qf_mulopt(float4 a, float4 b) {
    float2 p;

    p = two_prod(a.x, b.x);
    float4 r = float4(p.x, p.y, 0.0, 0.0);

    p = two_prod(a.x, b.y);
    r = qf_add(r, float4(0, p.x, p.y, 0));
    
    p = two_prod(a.y, b.x);
    r = qf_add(r, float4(0, p.x, p.y, 0));

    p = two_prod(a.x, b.z);
    r = qf_add(r, float4(0, 0, p.x, p.y));
    
    p = two_prod(a.z, b.x);
    r = qf_add(r, float4(0, 0, p.x, p.y));
    
    p = two_prod(a.y, b.y);
    r = qf_add(r, float4(0, 0, p.x, p.y));

    return r;
}

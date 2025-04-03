//
//  f64.metal
//  Metal64
//
//  Created by Dirk Braner on 23.12.24.
//

#include <metal_stdlib>

#include "f64.h"

using namespace metal;

/// Square root of f64 value
f64 sqrt(f64 a) {
    return f64(sqrt_f64(a.v));
}

/// Exponential function
f64 exp(f64 a) {
    return f64(exp_f64(a.v));
}

/// Natural logarithm
f64 log(f64 a) {
    return f64(log_f64(a.v));
}

/// Sine
f64 sin(f64 a) {
    return f64(sin_f64(a.v));
}

/// Cosine
f64 cos(f64 a) {
    return f64(cos_f64(a.v));
}

/// Tangent
f64 tan(f64 a) {
    return f64(tan_f64(a.v));
}

f64 asin(f64 a) {
    return f64(asin_f64(a.v));
}

f64 acos(f64 a) {
    return f64(acos_f64(a.v));
}

f64 atan(f64 a) {
    return f64(atan_f64(a.v));
}

f64 atan2(f64 a, f64 b) {
    return f64(atan2_f64(a.v, b.v));
}

// Overloaded operators

f64 operator + (f64 a, f64 b) {
    return f64(add_f64(a.v, b.v));
}

f64 operator + (f64 a, float b) {
    return f64(add_f64(a.v, float2(b, 0.0f)));
}

f64 operator + (float b, f64 a) {
    return f64(add_f64(a.v, float2(b, 0.0f)));
}

f64 operator - (f64 a, f64 b) {
    return f64(add_f64(a.v, -b.v));
}

f64 operator - (f64 a, float b) {
    return f64(sub_f64(a.v, float2(b, 0.0f)));
}

f64 operator - (float b, f64 a) {
    return f64(sub_f64(a.v, float2(b, 0.0f)));
}

f64 operator * (f64 a, f64 b) {
    return f64(mul_f64(a.v, b.v));
}

f64 operator * (f64 a, float b) {
    return f64(mulds(a.v, b));
}

f64 operator * (float a, f64 b) {
    return f64(mulds(b.v, a));
}

f64 operator / (f64 a, f64 b) {
    return f64(div_f64(a.v, b.v));
}

f64 operator / (f64 a, float b) {
    return f64(div_f64(a.v, float2(b, 0.0f)));
}

f64 operator / (float b, f64 a) {
    return f64(div_f64(a.v, float2(b, 0.0f)));
}

bool operator == (f64 a, f64 b) {
    return all(a.v == b.v);
}

bool operator != (f64 a, f64 b) {
    return any(a.v != b.v);
}

bool operator < (f64 a, f64 b) {
    return lt(a.v, b.v);
}

bool operator > (f64 a, f64 b) {
    return gt(a.v, b.v);
}

bool operator <= (f64 a, f64 b) {
    return le(a.v, b.v);
}

bool operator >= (f64 a, f64 b) {
    return ge(a.v, b.v);
}

bool isZero(f64 a) {
    return all(a.v == 0.0);
}

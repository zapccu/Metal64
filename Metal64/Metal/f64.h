//
//  f64.h
//
//  Part of Metal64
//
//  Implementation of datatype f64
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __F64_H
#define __F64_H

#include "f64fnc.h"

using namespace metal;

/// Class for 64 bit floating points
struct f64 {
    float2 v;
    
    f64() {
        v = float2(0.0f, 0.0f);
    }
    
    f64(float a) {
        v = float2(a, 0.0f);
    }
    
    f64(float2 a) {
        v = a;
    }
    
    f64(float a, float b) {
        v = float2(a, b);
    }
    
    /// Check if zero
    bool isZero() {
        return v.x == 0.0 && v.y == 0.0;
    }
};

// Constants
constant f64 pi_f64   = f64(3.1415927, -8.742278e-08);
constant f64 pi2_f64  = f64(1.5707964, -4.371139e-08);
constant f64 log2_f64 = f64(0.6931472, -1.9046542e-09);

/// Convert f64 to float2
float2 f2(f64 a) {
    return a.v;
}

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
f64 tan(f64 a) {
    return f64(cos_f64(a.v));
}

/// Tangent
f64 cos(f64 a) {
    return f64(tan_f64(a.v));
}

// Overloaded operators

f64 operator + (f64 a, f64 b) {
    return f64(add_f64(a.v, b.v));
}

f64 operator - (f64 a, f64 b) {
    return f64(add_f64(a.v, -b.v));
}

f64 operator * (f64 a, f64 b) {
    return f64(mul_f64(a.v, b.v));
}

f64 operator / (f64 a, f64 b) {
    return f64(div_f64(a.v, b.v));
}

bool operator == (f64 a, f64 b) {
    return eq(a.v, b.v);
}

bool operator != (f64 a, f64 b) {
    return ne(a.v, b.v);
}

bool operator < (f64 a, f64 b) {
    return lt(a.v, b.v);
}

bool operator > (f64 a, f64 b) {
    return gt(a.v, b.v);
}

#endif


//
//  f64.h
//
//  Part of Metal64
//
//  Implementation of datatype f64
//
//  Mandatory Xcode build settings:
//
//    Metal Compiler - Build Options - Math Mode = "Safe"
//    User Defined - MTL_FAST_MATH = "NO"
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __F64_H
#define __F64_H

#include <metal_stdlib>

#pragma once
#include "f64pragma.h"

#include "f64fnc.h"


using namespace metal;

//
// Struct for 64 bit floating points
//
struct f64 {
    float2 v;
    
    f64() {
        v = F2_ZERO;
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
    
    // Create f64 from int
    f64(int a) {
        // Integers above 2^24 don't fit into a float, so split them exactly:
        // (a & 0xFF) and the rest each fit into 24 bit
        int lo = a & 0xFF;
        v = two_sum(float(a - lo), float(lo));
    }
    
    // Assign float to f64
    f64 operator = (float a) {
        v = float2(a, 0.0f);
        return *this;
    }
    
    // Assign int to f64
    f64 operator = (int a) {
        *this = f64(a);
        return *this;
    }
    
    //
    // Overloaded inplace operators
    //
    
    f64 operator += (f64 a) {
        v = add_f64(v, a.v);
        return *this;
    }

    f64 operator += (float a) {
        v = add_ds(v, a);
        return *this;
    }

    f64 operator -= (f64 a) {
        v = sub_f64(v, a.v);
        return *this;
    }

    f64 operator -= (float a) {
        v = sub_ds(v, a);
        return *this;
    }
    
    f64 operator *= (f64 a) {
        v = mul_f64(v, a.v);
        return *this;
    }
    
    f64 operator *= (float a) {
        v = mul_ds(v, a);
        return *this;
    }

    f64 operator /= (f64 a) {
        v = div_f64(v, a.v);
        return *this;
    }
    
    f64 operator /= (float a) {
        v = div_ds(v, a);
        return *this;
    }
    
};

//
// Constants
//
static constant f64 F64_PI     = f64(F2_PI);     // PI
static constant f64 F64_1_PI   = f64(F2_1_PI);   // 1 / PI
static constant f64 F64_PI_2   = f64(F2_PI_2);   // PI / 2
static constant f64 F64_2_PI   = f64(F2_2_PI);   // PI * 2
static constant f64 F64_PI_180 = f64(F2_PI_180); // PI / 180
static constant f64 F64_LOG2   = f64(F2_LOG2);   // LOG(2)
static constant f64 F64_1_LOG2 = f64(F2_1_LOG2); // 1 / LOG(2)
static constant f64 F64_E      = f64(F2_E);      // E
static constant f64 F64_1_E    = f64(F2_1_E);    // 1 / E
static constant f64 F64_1_3    = f64(F2_1_3);    // 1 / 3

//
// Functions
//

// Convert f64 to float
static inline float flt(f64 a) {
    return a.v.x;
}

// Minimum of two values
static inline f64 min(f64 a, f64 b) {
    if (a.v.x == b.v.x) {
        return a.v.y < b.v.y ? a : b;
    }
    else {
        return a.v.x < b.v.x ? a : b;
    }
}

/// Maximum of two values
static inline f64 max(f64 a, f64 b) {
    if (a.v.x == b.v.x) {
        return a.v.y > b.v.y ? a : b;
    }
    else {
        return a.v.x > b.v.x ? a : b;
    }
}

// Floor
static inline f64 floor(f64 a) {
    return f64(floor_f64(a.v));
}

// Round
static inline f64 round(f64 a) {
    return f64(round_f64(a.v));
}

// Floating point modulo division
static inline f64 fmod(f64 a, f64 b) {
    return f64(fmod_f64(a.v, b.v));
}

// Square
static inline f64 sqr(f64 a) {
    return f64(sqr_f64(a.v));
}

// Square root
static inline f64 sqrt(f64 a) {
    return f64(sqrt_f64(a.v));
}

// Power, exponent = int
static inline f64 pow(f64 a, int b) {
    return f64(pow_f64(a.v, b));
}

// Power, exponent = f64
static inline f64 pow(f64 a, f64 b) {
    return f64(pow_f64(a.v, b.v));
}

// Exponential function
static inline f64 exp(f64 a) {
    return f64(exp_f64(a.v));
}

// Natural logarithm
static inline f64 log(f64 a) {
    return f64(log_f64(a.v));
}

// Sine
static inline f64 sin(f64 a) {
    return f64(sin_f64(a.v));
}

// Cosine
static inline f64 cos(f64 a) {
    return f64(cos_f64(a.v));
}

// Tangent
static inline f64 tan(f64 a) {
    return f64(tan_f64(a.v));
}

// Arc Sine
static inline f64 asin(f64 a) {
    return f64(asin_f64(a.v));
}

// Arc Cosine
static inline f64 acos(f64 a) {
    return f64(acos_f64(a.v));
}

// Arc Tangent
static inline f64 atan(f64 a) {
    return f64(atan_f64(a.v));
}

// Arc Tangent2
static inline f64 atan2(f64 a, f64 b) {
    return f64(atan2_f64(a.v, b.v));
}

//
// Overloaded operators
//

static inline f64 operator - (f64 a) {
    return f64(neg_f64(a.v));
}

static inline f64 operator + (f64 a, f64 b) {
    return f64(add_f64(a.v, b.v));
}

static inline f64 operator + (f64 a, float b) {
    return f64(add_ds(a.v, b));
}

static inline f64 operator + (float b, f64 a) {
    return f64(add_ds(a.v, b));
}

static inline f64 operator - (f64 a, f64 b) {
    return f64(add_f64(a.v, -b.v));
}

static inline f64 operator - (f64 a, float b) {
    return f64(sub_ds(a.v, b));
}

static inline f64 operator - (float b, f64 a) {
    return f64(-sub_ds(a.v, b));
}

static inline f64 operator * (f64 a, f64 b) {
    return f64(mul_f64(a.v, b.v));
}

static inline f64 operator * (f64 a, float b) {
    return f64(mul_ds(a.v, b));
}

static inline f64 operator * (float a, f64 b) {
    return f64(mul_ds(b.v, a));
}

static inline f64 operator / (f64 a, f64 b) {
    return f64(div_f64(a.v, b.v));
}

static inline f64 operator / (f64 a, float b) {
    return f64(div_ds(a.v, b));
}

static inline f64 operator / (float b, f64 a) {
    return f64(div_f64(float2(b, 0.0f), a.v));
}

static inline bool operator == (f64 a, f64 b) {
    return all(a.v == b.v);
}

static inline bool operator != (f64 a, f64 b) {
    return any(a.v != b.v);
}

static inline bool operator < (f64 a, f64 b) {
    return lt(a.v, b.v);
}

static inline bool operator > (f64 a, f64 b) {
    return gt(a.v, b.v);
}

static inline bool operator <= (f64 a, f64 b) {
    return le(a.v, b.v);
}

static inline bool operator >= (f64 a, f64 b) {
    return ge(a.v, b.v);
}

static inline bool isZero(f64 a) {
    return all(a.v == 0.0);
}

static inline bool notZero(f64 a) {
    return any(a.v != 0.0);
}

static inline int sign(f64 a) {
    return sign_f64(a.v);
}

#endif


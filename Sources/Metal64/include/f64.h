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

#include "f64fnc.h"
#include "f64iter.h"


using namespace metal;

// Struct for 64 bit floating points
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
    
    f64(int a) {
        v = float2(float(a), 0.0f);
    }
    
    f64 operator = (float a) {
        v = float2(a, 0.0f);
        return *this;
    }
    
    f64 operator = (int a) {
        v = float2(float(a), 0.0f);
        return *this;
    }
    
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
};

// Constants
static constant f64 F64_PI     = f64(3.1415927, -8.742278e-08);    // PI
static constant f64 F64_1_PI   = f64(0.31830987, 1.28412765e-08);  // 1 / PI
static constant f64 F64_PI_2   = f64(1.5707964, -4.371139e-08);    // PI / 2
static constant f64 F64_2_PI   = f64(6.2831855, -1.7484555e-07);   // PI * 2
static constant f64 F64_PI_180 = f64(0.017453292, 1.351996e-10);   // PI / 180
static constant f64 F64_LOG2   = f64(0.6931472, -1.9046542e-09);   // LOG(2)
static constant f64 F64_1_LOG2 = f64(1.442695, 1.925963e-08);      // 1 / LOG(2)
static constant f64 F64_E      = f64(2.7182817, 8.2548404e-08);    // E
static constant f64 F64_1_E    = f64(0.36787945, -9.149755e-09);   // 1 / E
static constant f64 F64_1_3    = f64(0.33333334, -9.934108e-09);   // 1 / 3

/// Convert f64 to float
static inline float flt(f64 a) {
    return a.v.x;
}

/// Minimum of two values
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

/// Square
static inline f64 sqr(f64 a) {
    return f64(sqr_f64(a.v));
}

/// Square root
static inline f64 sqrt(f64 a) {
    return f64(sqrt_f64(a.v));
}

// Power, exponent = int
static inline f64 pow(f64 a, int b) {
    return f64(pow_f64(a.v, b));
}

// Power, exponent = f64
static inline f64 pow(f64 a, f64 b) {
    return f64(exp_iterate(mul_f64(b.v, log_iterate(a.v))));
}

// Exponential function
static inline f64 exp(f64 a) {
    return f64(exp_iterate(a.v));
}

// Natural logarithm
static inline f64 log(f64 a) {
    return f64(log_iterate(a.v));
}

// Sine
static inline f64 sin(f64 a) {
    return f64(sincos_iterate(a.v).xy);
}

// Cosine
static inline f64 cos(f64 a) {
    return f64(sincos_iterate(a.v).zw);
}

// Tangent
static inline f64 tan(f64 a) {
    return f64(tan_iterate(a.v));
}

// Arc Sine
static inline f64 asin(f64 a) {
    return f64(asin_iterate(a.v));
}

// Arc Cosine
static inline f64 acos(f64 a) {
    return f64(acos_iterate(a.v));
}

// Arc Tangent
static inline f64 atan(f64 a) {
    return f64(atan2_iterate(a.v, F2_ONE));
}

// Arc Tangent2
static inline f64 atan2(f64 a, f64 b) {
    return f64(atan2_iterate(a.v, b.v));
}

// Overloaded operators

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
    return f64(div_f64(a.v, float2(b, 0.0f)));
}

static inline f64 operator / (float b, f64 a) {
    return f64(div_f64(a.v, float2(b, 0.0f)));
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


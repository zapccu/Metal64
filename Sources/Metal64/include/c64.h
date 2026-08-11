
//
//  c64.h
//
//  Part of Metal64
//
//  Implementation of Metal datatype complex f64 = c64
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __C64_H
#define __C64_H

#include "f64.h"

using namespace metal;


struct c64 {
    float4 v;
    
    c64() {
        v = float4(0.0, 0.0, 0.0, 0.0);
    }
    
    /// Initialize real part with 32 bit floating point value
    c64(float a) {
        v = float4(a, 0.0, 0.0, 0.0);
    }
    
    /// Initialize real part with 64 bit floating point value
    c64(float2 a) {
        v.xy = a;
    }
    
    /// Initialize real and imag part with 64 bit floating point values
    c64(float2 a, float2 b) {
        v = float4(a, b);
    }
    
    c64(f64 a) {
        v.xy = a.v;
    }
    
    c64(f64 a, f64 b) {
        v = float4(a.v, b.v);
    }
    
    /// Initialize c64 with float4 vector (compatible with Swift type Complex2)
    c64(float4 a) {
        v = a;
    }
    
    /// Initialize c64 with float
    c64 operator = (float a) {
        v = float4(a, 0.0f, 0.0f, 0.0f);
        return *this;
    }
    
    /// Initialize c64 with f64
    c64 operator = (f64 a) {
        v = float4(a.v, float2(0.0f, 0.0f));
        return *this;
    }
    
    /// Return real part of complex number
    inline f64 real() {
        return f64(v.xy);
    }
    
    /// Return imaginary part of complex number
    inline f64 imaginary() {
        return f64(v.zw);
    }
};

static inline c64 operator + (c64 a, c64 b) {
    return c64(add_c64(a.v, b.v));
}

static inline c64 operator + (c64 a, f64 b) {
    return c64(add_f64(a.v.xy, b.v), a.v.zw);
}

static inline c64 operator + (f64 b, c64 a) {
    return c64(add_f64(a.v.xy, b.v), a.v.zw);
}

static inline c64 operator + (c64 a, float b) {
    return c64(add_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

static inline c64 operator + (float b, c64 a) {
    return c64(add_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

static inline c64 operator - (c64 a, c64 b) {
    return c64(sub_c64(a.v, b.v));
}

static inline c64 operator - (c64 a, f64 b) {
    return c64(sub_f64(a.v.xy, b.v), a.v.zw);
}

static inline c64 operator - (f64 b, c64 a) {
    return c64(sub_f64(b.v, a.v.xy), a.v.zw);
}

static inline c64 operator - (c64 a, float b) {
    return c64(sub_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

static inline c64 operator - (float b, c64 a) {
    return c64(sub_f64(float2(b, 0.0f), a.v.xy), a.v.zw);
}

static inline c64 operator * (c64 a, c64 b) {
    return c64(mul_c64(a.v, b.v));
}

static inline c64 operator * (c64 a, f64 b) {
    return c64(mul_f64(a.v.xy, b.v), mul_f64(a.v.zw, b.v));
}

static inline c64 operator * (f64 b, c64 a) {
    return c64(mul_f64(a.v.xy, b.v), mul_f64(a.v.zw, b.v));
}

static inline c64 operator * (c64 a, float b) {
    return c64(mul_ds(a.v.xy, b), mul_ds(a.v.zw, b));
}

static inline c64 operator * (float b, c64 a) {
    return c64(mul_ds(a.v.xy, b), mul_ds(a.v.zw, b));
}

static inline c64 operator / (c64 a, c64 b) {
    return c64(div_c64(a.v, b.v));
}

static inline c64 operator / (c64 a, f64 b) {
    return c64(div_f64(a.v.xy, b.v), div_f64(a.v.zw, b.v));
}

static inline c64 operator / (f64 b, c64 a) {
    return c64(div_f64(b.v, a.v.xy), div_f64(b.v, a.v.zw));
}

static inline c64 operator / (c64 a, float b) {
    return c64(div_f64(a.v.xy, float2(b, 0.0f)), div_f64(a.v.zw, float2(b, 0.0f)));
}

static inline c64 operator / (float b, c64 a) {
    return c64(div_f64(float2(b, 0.0f), a.v.xy), div_f64(float2(b, 0.0f), a.v.zw));
}

static inline bool isZero(c64 a) {
    return all(a.v == 0.0);
}

static inline bool notZero(c64 a) {
    return any(a.v != 0.0);
}

static inline bool operator == (c64 a, c64 b) {
    return all(a.v == b.v);
}

static inline bool operator != (c64 a, c64 b) {
    return any(a.v != b.v);
}

static inline c64 sqr(c64 a) {
    return c64(sqr_c64(a.v));
}

static inline c64 sqrt(c64 a) {
    return c64(sqrt_c64(a.v));
}

static inline c64 exp(c64 a) {
    return c64(exp_c64(a.v));
}

static inline f64 norm(c64 a) {
    return f64(norm_c64(a.v));
}

static inline f64 abs(c64 a) {
    return f64(abs_c64(a.v));
}

// Argument: arg(a+bi) = atan2(b, a)
static inline f64 arg(c64 a) {
    return f64(atan2_f64(a.v.zw, a.v.xy));
}



#endif


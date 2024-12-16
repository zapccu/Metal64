
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

#include "f64helper.h"
#include "f64fnc.h"
#include "f64.h"

using namespace metal;

class c64 {
public:
    float2 r;
    float2 i;
    
    c64() {
        r = float2(0.0, 0.0);
        i = float2(0.0, 0.0);
    }
    
    /// Initialize real part with 64 bit floating point value
    c64(float2 a) {
        r = a;
        i = float2(0.0, 0.0);
    }
    
    /// Initialize real and imag part with 64 bit floating point values
    c64(float2 a, float2 b) {
        r = a;
        i = b;
    }
    
    /// Initialize real and imag part with float4 vector (compatible with Swift type Complex2)
    c64(float4 a) {
        r = a.xy;
        i = a.zw;
    }
};

/// Convert c64 to float4
float4 f4(c64 a) {
    return float4(a.r.x, a.r.y, a.i.x, a.i.y);
}

// Overloaded operators

c64 operator + (c64 a, c64 b) {
    return c64(add_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

c64 operator - (c64 a, c64 b) {
    return c64(sub_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

c64 operator * (c64 a, c64 b) {
    return c64(mul_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

f64 norm(c64 a) {
    return f64(norm_c64(float4(a.r.xy, a.i.xy)));
}

f64 abs(c64 a) {
    return f64(abs_c64(float4(a.r.xy, a.i.xy)));
}

#endif


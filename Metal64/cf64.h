
//
//  cf64.h
//
//  Part of Metal64
//
//  Implementation of Metal datatype complex f64
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __CF64_H
#define __CF64_H

#include "f64helper.h"
#include "f64fnc.h"
#include "f64.h"

using namespace metal;

class cf64 {
public:
    float2 r;
    float2 i;
    
    cf64() {
        r = float2(0.0, 0.0);
        i = float2(0.0, 0.0);
    }
    
    /// Initialize real part with 64 bit floating point value
    cf64(float2 a) {
        r = a;
        i = float2(0.0, 0.0);
    }
    
    /// Initialize real and imag part with 64 bit floating point values
    cf64(float2 a, float2 b) {
        r = a;
        i = b;
    }
    
    /// Initialize real and imag part with float4 vector (compatible with Swift type Complex2)
    cf64(float4 a) {
        r = a.xy;
        i = a.zw;
    }
};

cf64 operator + (cf64 a, cf64 b) {
    return cf64(add_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

cf64 operator - (cf64 a, cf64 b) {
    return cf64(sub_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

cf64 operator * (cf64 a, cf64 b) {
    return cf64(mul_c64(float4(a.r.xy, a.i.xy), float4(b.r.xy, b.i.xy)));
}

f64 norm_cf64(cf64 a) {
    return abs_f64(float4(a.r.xy, a.i.xy));
}
f64 abs_cf64(cf64 a) {
    return abs_f64(float4(a.r.xy, a.i.xy));
}

#endif


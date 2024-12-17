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
class f64 {
public:
    float2 v;
    
    f64() {
        v = float2(0.0, 0.0);
    }
    
    f64(float a) {
        v = float2(a, 0.0);
    }
    
    f64(float2 a) {
        v = a;
    }
};

/// Convert f64 to float2
float2 f2(f64 a) {
    return a.v;
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


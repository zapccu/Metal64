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
    
    f64 operator = (float a) {
        v = float2(a, 0.0f);
        return *this;
    }
    
    /// Check if zero
    bool isZero() {
        return all(v == 0.0);
    }
};

// Constants
constant f64 pi_f64   = f64(3.1415927, -8.742278e-08);
constant f64 pi2_f64  = f64(1.5707964, -4.371139e-08);
constant f64 log2_f64 = f64(0.6931472, -1.9046542e-09);

f64 sqrt(f64);
f64 exp(f64);
f64 log(f64);
f64 sin(f64);
f64 cos(f64);
f64 tan(f64);
f64 asin(f64);
f64 acos(f64);
f64 atan(f64);
f64 atan2(f64, f64);

f64 operator + (f64, f64);
f64 operator + (f64, float);
f64 operator + (float, f64);
f64 operator - (f64, f64);
f64 operator - (f64, float);
f64 operator - (float, f64);
f64 operator * (f64, f64);
f64 operator * (f64, float);
f64 operator * (float, f64);
f64 operator / (f64, f64);
f64 operator / (f64, float);
f64 operator / (float, f64);

bool operator == (f64, f64);
bool operator != (f64, f64);
bool operator < (f64, f64);
bool operator > (f64, f64);

bool isZero(f64);

#endif


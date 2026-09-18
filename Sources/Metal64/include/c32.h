//
//  c32.h
//  Metal64
//
//  Created by Dirk Braner on 13.08.26.
//

#ifndef __C32_H
#define __C32_H

#include "f64.h"

using namespace metal;


struct c32 {
    float2 v;
    
    c32() {
        v = float2(0.0, 0.0);
    }
    
    /// Initialize real part with 32 bit floating point value
    c32(float a) {
        v = float2(a, 0.0);
    }
    
    /// Initialize real part with 32 bit complex value
    c32(float2 a) {
        v = a;
    }
    
    /// Initialize real and imag part with 32 bit floating point values
    c32(float a, float b) {
        v = float2(a, b);
    }
    
    /// Initialize c32 with float
    c32 operator = (float a) {
        v = float2(a, 0.0f);
        return *this;
    }
    
    /// Return real part of complex number
    inline float real() {
        return v.x;
    }
    
    /// Return imaginary part of complex number
    inline float imaginary() {
        return v.y;
    }
};

//
// Add
//
static inline c32 operator + (c32 a, c32 b) {
    return c32(a.v + b.v);
}

static inline c32 operator + (c32 a, float b) {
    return c32(a.v.x + b, a.v.y);
}

static inline c32 operator + (float b, c32 a) {
    return c32(a.v.x + b, a.v.y);
}

//
// Subtract
//
static inline c32 operator - (c32 a, c32 b) {
    return c32(a.v - b.v);
}

static inline c32 operator + (c32 a, float b) {
    return c32(a.v.x - b, a.v.y);
}

static inline c32 operator + (float b, c32 a) {
    return c32(a.v.x - b, a.v.y);
}

//
// Multiply
//
static inline c32 operator * (c32 a, c32 b) {
    float r1 = a.v.x * b.v.x;    // a.r * b.r
    float r2 = a.v.y * b.v.y;    // a.i * b.i
    float i1 = a.v.x * b.v.y;    // a.r * b.i
    float i2 = a.v.y * b.v.x;    // a.i * b.r
    return c32(r1 - r2, i1 + i2);
}

static inline c32 operator * (c32 a, float b) {
    return c32(a.v * b);
}

static inline c32 operator * (float b, c32 a) {
    return c32(a.v * b);
}

//
// Divide
//
static inline c32 operator / (c32 a, c32 b) {
    float d = b.v.x * b.v.x + b.v.y * b.v.y;
    float r = (a.v.x * b.v.x + a.v.y * b.v.y) / d;
    float i = (a.v.y * b.v.x - a.v.x * b.v.y) / d;
    return c32(r, i);
}

static inline c32 operator / (c32 a, float b) {
    float d = b * b;
    return c32(a * b / d);
}

static inline c32 operator / (float a, c32 b) {
    float d = b.v.x * b.v.x + b.v.y * b.v.y;
    float r = (a.v.x * b.v.x) / d;
    float i = (-a.v.x * b.v.y) / d;
    return c32(r, i);
}

//
// Compare
//
static inline bool isZero(c32 a) {
    return all(a.v == 0.0);
}

static inline bool notZero(c32 a) {
    return any(a.v != 0.0);
}

static inline bool operator == (c32 a, c32 b) {
    return all(a.v == b.v);
}

static inline bool operator != (c32 a, c32 b) {
    return any(a.v != b.v);
}

static inline c32 sqr(c32 a) {
    float r1 = a.v.x * a.v.x;
    float r2 = a.v.y * a.v.y;
    float i1 = a.v.x * a.v.y;
    return c32(r1 - r2, i1 + i2)
}

static inline c32 sqrt(c32 a) {
    float dc = abs(a);
    float r = sqrt((dc + a.v.x) * 0.5);
    float i = a.v.y < 0 ? -sqrt((dc - a.v.x) * 0.5) : sqrt((dc - a.v.x) * 0.5);
    return c32(r, i);
}

static inline c32 exp(c32 a) {
    float e = exp(a.v.x);
    return c32(e * cos(a.v.y), e * sin(a.v.y));
}

static inline float norm(c32 a) {
    return a.v.x * a.v.x + a.v.y * a.v.y;
}

static inline float abs(c32 a) {
    return sqrt(norm(a))
}

// Argument: arg(a+bi) = atan2(b, a)
static inline float arg(c32 a) {
    return c32(atan2(a.v.y, a.v.x));
}




#endif


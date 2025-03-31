//
//  float64.cpp, part of float64
//
//  Emulation of 64 bit floating point numbers
//
//  Original Code by Detlef_a (Nickname in the www.mikrocontroller.net forum).
//  Extensions (trigonometric functions et al.) und changes by Florian Königstein, mail@virgusta.eu .
//
//  Reference: https://www.mikrocontroller.net/topic/85256
//
//  Ported to C++, adapted to MacOS / Metal by Dirk Braner on 27.12.24.
//

#ifdef __METAL_VERSION__
#include <metal_stdlib>
#endif

#include "float64.h"

#ifdef __METAL_VERSION__
using namespace metal;
#endif

float64::float64(float a) {
    TPTR int32_t* i;
    uint8_t  f_sign;
    int16_t f_ex;
    uint64_t  w;
    float64_t f64;
    
    if(a == 0.0) {
        v = FLOAT64_NUMBER_PLUS_ZERO;
        return;
    }

    i = (TPTR int32_t *) & a;
    w = ((*i) & 0x7fffffl);
    f_ex  =  (*i >> 23) & 0xff;
    f_sign = (*i >> 31) & 1;

    if(0 == f_ex && 0 != w)
        f_ex += 29 + 0x3ff - 0x7e;
    else if(255 == f_ex) // +/-INF oder NaN
        v = 0 == w ? (f_sign ? FLOAT64_MINUS_INFINITY : FLOAT64_PLUS_INFINITY) : FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION;
    else
    {
        w |= 0x800000; // Falls KEINE denormalisierte float-Zahl (32 Bits) vorliegt, wird das implizite f¸hrende 1-Bit in w erg‰nzt.
        if(f_ex) f_ex += 29+0x3ff-0x7f;
        // F¸r ==> FLOAT (32 Bits) <== gilt: NICHT ALLE denormalisierten FLOAT-Zahlen werden als Null interpretiert.
    }
    f_combi_from_fixpoint(&f64, f_sign, f_ex, &w);
    
    v = f64;
}

float float64::toFloat() {
    uint8_t f_sign;
    int16_t f_ex;
    uint32_t ui32;
    float32_t f32;
    uint64_t w;
  
    uint64_t fx = v;
    //f_split64(&fx, &f_sign, &f_ex, &w, 0);
    f_split64(fx, &f_sign, &f_ex, &w, 0);

    if(f_ex >= 1023 - 149) {
        if(f_ex > 1023 + 127) {
            if(f_ex == 2047 && 0 != w)
                ui32 = 0xfffff;
            else
                ui32 = 0;
            f_ex = 255;
     }
     else {
         ui32=(w >> (52 - 23)) & 0x7fffff;
         if(f_ex < 1023 - 126) {
            ui32 = (ui32 | 0x800000) >> (1023 - 126 - f_ex);
            f_ex = 0;
         }
         else
            f_ex = (f_ex - 0x3ff + 0x7f) & 0xff;
     }
 }
 else
    ui32=0;
 
    ui32 |= ((uint32_t)f_sign << 31) | ((uint32_t)f_ex << 23);
    f32= *((TPTR float32_t *)&ui32);
 
    return(f32);
}


// ----------------------------------------------
//  Overloaded operators
// ----------------------------------------------

float64 operator + (float64 a, float64 b) {
    return float64(f_add(a.v, b.v));
}

float64 operator + (float64 a, float b) {
    return float64(f_add(a.v, float64(b).v));
}

float64 operator + (float a, float64 b) {
    return float64(f_add(float64(a).v, b.v));
}

float64 operator - (float64 a, float64 b) {
    return float64(f_sub(a.v, b.v));
}

float64 operator - (float64 a, float b) {
    return float64(f_sub(a.v, float64(b).v));
}

float64 operator - (float a, float64 b) {
    return float64(f_sub(float64(a).v, b.v));
}

float64 operator * (float64 a, float64 b) {
    return float64(f_mul(a.v, b.v));
}

float64 operator * (float64 a, float b) {
    return float64(f_mul(a.v, float64(b).v));
}

float64 operator * (float a, float64 b) {
    return float64(f_mul(float64(a).v, b.v));
}

float64 operator / (float64 a, float64 b) {
    return float64(f_div(a.v, b.v));
}

float64 operator / (float64 a, float b) {
    return float64(f_div(a.v, float64(b).v));
}

float64 operator / (float a, float64 b) {
    return float64(f_div(float64(a).v, b.v));
}

bool operator == (float64 a, float64 b) {
    return f_compare(a.v, b.v) == 0;
}

bool operator != (float64 a, float64 b) {
    return f_compare(a.v, b.v) != 0;
}

bool operator < (float64 a, float64 b) {
    return f_compare(a.v, b.v) < 0;
}

bool operator > (float64 a, float64 b) {
    return f_compare(a.v, b.v) > 0;
}

bool operator <= (float64 a, float64 b) {
    return f_compare(a.v, b.v) <= 0;
}

bool operator >= (float64 a, float64 b) {
    return f_compare(a.v, b.v) >= 0;
}


// ----------------------------------------------
//  Mathematical functions for type float64
// ----------------------------------------------

float64 abs(float64 a) {
    return float64(a.v & 0x7fffffffffffffff);
}

float64 sqrt(float64 a) {
    return float64(f_sqrt(a.v));
}

float64 exp(float64 a) {
    return float64(f_exp(a.v));
}

float64 log(float64 a) {
    return float64(f_log(a.v));
}

float64 pow(float64 a, float64 b) {
    return float64(f_pow(a.v, b.v));
}

float64 pow(float64 a, int b) {
    return float64(f_pow(a.v, b));
}


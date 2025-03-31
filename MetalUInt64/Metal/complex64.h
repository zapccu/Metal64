//
//  complex64.h
//  ulong64
//
//  Created by Dirk Braner on 30.12.24.
//


#ifndef __COMPLEX64_H
#define __COMPLEX64_H

#include "float64.h"


class complex64 {
public:
    float64 r;
    float64 i;
    
    complex64(float a = 0.0, float b = 0.0) {
        r = float64(a);
        i = float64(b);
    }
    
    complex64(float64 a, float64 b = float64(FLOAT64_NUMBER_PLUS_ZERO)) {
        r = a;
        i = b;
    }
    
    complex64(float64_t a, float64_t b = FLOAT64_NUMBER_PLUS_ZERO) {
        r = float64(a);
        i = float64(b);
    }
    
    complex64 operator = (float a) {
        *this = complex64(a);
        return *this;
    }
    
    complex64 operator - () {
        return complex64(-r, -i);
    }
};


// Arithmetic operations

complex64 c_mul(complex64, complex64);
complex64 c_sqr(complex64);
complex64 c_div(complex64, complex64);


// Overloaded operators

complex64 operator + (complex64, complex64);
complex64 operator + (complex64, float64);
complex64 operator + (float64, complex64);
complex64 operator + (complex64, float);
complex64 operator + (float, complex64);
complex64 operator - (complex64, complex64);
complex64 operator - (complex64, float64);
complex64 operator - (float64, complex64);
complex64 operator - (complex64, float);
complex64 operator - (float, complex64);
complex64 operator * (complex64, complex64);
complex64 operator * (complex64, float64);
complex64 operator * (float64, complex64);
complex64 operator * (complex64, float);
complex64 operator * (float, complex64);
complex64 operator / (complex64, complex64);
complex64 operator / (complex64, float64);
complex64 operator / (float64, complex64);
complex64 operator / (complex64, float);
complex64 operator / (float, complex64);

bool operator == (complex64, complex64);
bool operator == (complex64, float64);
bool operator == (complex64, float);
bool operator != (complex64, complex64);
bool operator != (complex64, float64);
bool operator != (complex64, float);

float64 norm(complex64);
float64 abs(complex64);


#endif

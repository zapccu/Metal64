//
//  complex64.cpp
//
//  Created by Dirk Braner on 30.12.24.
//

#ifdef __METAL_VERSION__
#include <metal_stdlib>
#endif

#include "complex64.h"

#ifdef __METAL_VERSION__
using namespace metal;
#endif

// ------------------------------------
//  Complex addition
// ------------------------------------

complex64 operator + (complex64 a, complex64 b) {
    return complex64(f_add(a.r.v, b.r.v), f_add(a.i.v, b.i.v));
}

complex64 operator + (complex64 a, float64 b) {
    return complex64(f_add(a.r.v, b.v), a.i.v);
}

complex64 operator + (float64 b, complex64 a) {
    return complex64(f_add(a.r.v, b.v), a.i.v);
}

complex64 operator + (complex64 a, float b) {
    return complex64(f_add(a.r.v, float64(b).v), a.i.v);
}

complex64 operator + (float b, complex64 a) {
    return complex64(f_add(a.r.v, float64(b).v), a.i.v);
}


// ------------------------------------
//  Complex subtraction
// ------------------------------------

complex64 operator - (complex64 a, complex64 b) {
    return complex64(f_sub(a.r.v, b.r.v), f_sub(a.i.v, b.i.v));
}

complex64 operator - (complex64 a, float64 b) {
    return complex64(f_sub(a.r.v, b.v), a.i.v);
}

complex64 operator - (float64 b, complex64 a) {
    return complex64(f_sub(b.v, a.r.v), -a.i.v);
}

complex64 operator - (complex64 a, float b) {
    return complex64(f_sub(a.r.v, float64(b).v), a.i.v);
}

complex64 operator - (float b, complex64 a) {
    return complex64(f_sub(float64(b).v, a.r.v), -a.i.v);
}


// ------------------------------------
//  Complex multiplication
// ------------------------------------

complex64 operator * (complex64 a, complex64 b) {
    return c_mul(a, b);
}

complex64 operator * (complex64 a, float64 b) {
    return c_mul(a, complex64(b));
}

complex64 operator * (float64 b, complex64 a) {
    return c_mul(a, complex64(b));
}

complex64 operator * (complex64 a, float b) {
    return c_mul(a, complex64(b));
}

complex64 operator * (float b, complex64 a) {
    return c_mul(a, complex64(b));
}


// ------------------------------------
//  Complex division
// ------------------------------------

complex64 operator / (complex64 a, complex64 b) {
    return c_div(a, b);
}

complex64 operator / (complex64 a, float64 b) {
    return c_div(a, complex64(b));
}

complex64 operator / (float64 b, complex64 a) {
    return c_div(complex64(b), a);
}

complex64 operator / (complex64 a, float b) {
    return c_div(a, complex64(b));
}

complex64 operator / (float b, complex64 a) {
    return c_div(complex64(b), a);
}


// ------------------------------------
//  Complex functions
// ------------------------------------

float64 norm(complex64 a) {
    return float64(f_add(f_mul(a.r.v, a.r.v), f_mul(a.i.v, a.i.v)));
}

float64 abs(complex64 a) {
    return float64(f_sqrt(f_add(f_mul(a.r.v, a.r.v), f_mul(a.i.v, a.i.v))));
}


// ------------------------------------
//  Compare operations
// ------------------------------------

bool operator == (complex64 a, complex64 b) {
    return f_compare(a.r.v, b.r.v) == 0 && f_compare(a.i.v, b.i.v) == 0;
}

bool operator == (complex64 a, float64 b) {
    return f_compare(a.r.v, b.v) == 0 && a.i.isZero();
}

bool operator == (complex64 a, float b) {
    return f_compare(a.r.v, float64(b).v) == 0 && a.i.isZero();
}

bool operator != (complex64 a, complex64 b) {
    return f_compare(a.r.v, b.r.v) != 0 || f_compare(a.i.v, b.i.v) != 0;
}

bool operator != (complex64 a, float64 b) {
    return f_compare(a.r.v, b.v) != 0 || !(a.i.isZero());
}

bool operator != (complex64 a, float b) {
    return f_compare(a.r.v, float64(b).v) != 0 || !(a.i.isZero());
}

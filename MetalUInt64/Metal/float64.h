//
//  float64.h, part of float64
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

#ifndef __FLOAT64_H
#define __FLOAT64_H

#ifndef __METAL_VERSION__

#include <stdint.h>

#define TPTR

#else

#include <metal_stdlib>

using namespace metal;

#define TPTR thread

#endif


// Type definitions

typedef uint64_t float64_t; // IEEE 754 double precision floating point number
typedef float    float32_t; // IEEE 754 single precision floating point number


// Constants

#define F64_NAN_HI 0x7ff0000000000000
#define F64_NAN_LO 0x000fffffffffffff
#define FLOAT64_E   ((float64_t)0x4005bf0a8b145769)    // 2.7182818284590452
#define FLOAT64_PI  ((float64_t)0x400921fb54442d18)    // 3.1415926535897932
#define FLOAT64_LOG2 ((float64_t)0x3FE62E42FEFA39EF)    // 0.6931471805599453
#define FLOAT64_NUMBER_ONE                          ((float64_t)0x3ff0000000000000)    // 1.0
#define FLOAT64_NUMBER_PLUS_ZERO                    ((float64_t)0x0000000000000000)    // 0.0
#define FLOAT64_ONE_POSSIBLE_NAN_REPRESENTATION     ((float64_t)0x7fffffffffffffff)    // NaN
#define FLOAT64_PLUS_INFINITY                       ((float64_t)0x7ff0000000000000)    // +INF
#define FLOAT64_MINUS_INFINITY                      ((float64_t)0xfff0000000000000)    // -INF


// Helper functions

void f_setsign(TPTR float64_t *, int8_t);
float64_t f_setsign(float64_t, int8_t);
uint8_t f_getsign(float64_t);
//void f_split64(TPTR float64_t *, TPTR uint8_t *, TPTR int16_t *, TPTR uint64_t *, uint8_t);
void f_split64(float64_t, TPTR uint8_t *, TPTR int16_t *, TPTR uint64_t *, uint8_t);
//void f_split_to_fixpoint(TPTR float64_t *, TPTR uint8_t *, TPTR int16_t *, TPTR uint64_t *, int16_t);
void f_split_to_fixpoint(float64_t, TPTR uint8_t *, TPTR int16_t *, TPTR uint64_t *, int16_t);
void f_combi_from_fixpoint(TPTR float64_t *, uint8_t, int16_t, TPTR uint64_t *);
int8_t f_shift_left_until_bit63_set(TPTR uint64_t *);
uint64_t approx_high_uint64_word_of_uint64_mult_uint64(TPTR uint64_t *, TPTR uint64_t *, uint8_t);
uint64_t approx_high_uint64_word_of_uint64_mult_uint64_pbv_y(TPTR uint64_t *, uint64_t, uint8_t);
uint64_t approx_inverse_of_fixpoint_uint64(TPTR uint64_t *);
void f_addsub2(TPTR float64_t *, float64_t, float64_t, uint8_t, TPTR uint8_t *);
uint64_t f_eval_function_by_rational_approximation_fixpoint(uint64_t, uint8_t, uint8_t, TPTR uint64_t *, uint8_t);
float64_t f_mod_intern(float64_t, uint8_t, int16_t, TPTR uint64_t *, TPTR float64_t *);
long f_float64_to_long(float64_t);
uint64_t rounded_sqrt_of_integer128(uint64_t, uint64_t);


// Definition of type float64

class float64 {
public:
    uint64_t v;
    
    /// Default constructor
    float64() {
        v = FLOAT64_NUMBER_PLUS_ZERO;
    }
    
    /// Construct from float
    float64(float a);

    /// Construct from float64
    float64(uint64_t a) {
        v = a;
    }

    /// Convert to float
    float toFloat();
    
    /// Check if value is not a number
    bool isNaN() {
        return F64_NAN_HI == (v & F64_NAN_HI) && 0 != (v & F64_NAN_LO);
    }
    
    /// Check if value is a real number / not +/-INF
    bool isFinite() {
        return F64_NAN_HI != (v & F64_NAN_HI);
    }
    
    /// Check if value is zero
    bool isZero() {
        return v == FLOAT64_NUMBER_PLUS_ZERO;
    }
    
    /// Assign float
    float64 operator = (float a) {
        *this = float64(a);
        return *this;
    }
    
    // Unary minus
    float64 operator - () {
        return float64(v ^ 0x8000000000000000);
    }
};


// Mathematical operations

float64_t f_abs(float64_t);
float64_t f_add(float64_t, float64_t);
float64_t f_sub(float64_t, float64_t);
float64_t f_mul(float64_t, float64_t);
float64_t f_div(float64_t, float64_t);
int8_t f_compare(float64_t, float64_t);


// Mathematical functions

float64_t f_sqrt(float64_t);
float64_t f_exp(float64_t);
float64_t f_log(float64_t);
float64_t f_pow(float64_t, float64_t);
float64_t f_pow(float64_t, int);


// Overloaded operators

float64 operator + (float64, float64);
float64 operator + (float64, float);
float64 operator + (float, float64);
float64 operator - (float64, float64);
float64 operator - (float64, float);
float64 operator - (float, float64);
float64 operator * (float64, float64);
float64 operator * (float64, float);
float64 operator * (float, float64);
float64 operator / (float64, float64);
float64 operator / (float64, float);
float64 operator / (float, float64);
bool operator == (float64, float64);
bool operator != (float64, float64);
bool operator < (float64, float64);
bool operator > (float64, float64);
bool operator <= (float64, float64);
bool operator >= (float64, float64);


// Overloaded functions

float64 abs(float64);
float64 sqrt(float64);
float64 exp(float64);
float64 log(float64);
float64 pow(float64, float64);
float64 pow(float64, int);

#endif

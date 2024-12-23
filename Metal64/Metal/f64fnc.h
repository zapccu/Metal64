//
//  f64fnc.h
//  Metal64
//
//  Created by Dirk Braner on 23.12.24.
//

#ifndef __F64FNC_H
#define __F64FNC_H

using namespace metal;

// ----------------------------------------------------------------------------
//  Constants
// ----------------------------------------------------------------------------

constant float2 pi_f2   = float2(3.1415927, -8.742278e-08);
constant float2 pi2_f2  = float2(1.5707964, -4.371139e-08);
constant float2 log2_f2 = float2(0.6931472, -1.9046542e-09);

float2 sumq(float, float);
float4 sump(float2, float2);
float4 split4(float2);
float2 prod(float, float);

float2 add_f64(float2, float2);
float2 sub_f64(float2, float2);
float2 mul_f64(float2, float2);
float2 sqr_f64(float2);
float2 mulds(float2, float);
float2 div_f64(float2, float2);

bool isZero(float2);

bool eq(float2, float2);
bool ne(float2, float2);
bool lt(float2, float2);
bool gt(float2, float2);
bool le(float2, float2);
bool ge(float2, float2);

float2 sqrt_f64(float2);
float2 exp_f64(float2);
float2 log_f64(float2);
float2 pow_f64(float2, float2);
float2 pow_f64(float2, int);

float4 sincos_f64(float2);
float2 sin_f64(float2);
float2 cos_f64(float2);
float2 tan_f64(float2);
float2 atan_iterate(float2, int);
float2 atan_f64(float2);
float2 atan2_f64(float2, float2);
float2 asin_f64(float2);
float2 acos_f64(float2);

float4 add_c64(float4, float4);
float4 sub_c64(float4, float4);
float4 mul_c64(float4, float4);
float4 sqr_c64(float4 a);
float4 div_c64(float4, float4);

bool eq(float4, float4);
bool ne(float4, float4);

float2 norm_c64(float4);
float2 abs_c64(float4);

#endif


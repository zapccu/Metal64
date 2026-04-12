//
//  f128.h
//  Metal64
//
//  Created by Dirk Braner on 12.04.26.
//

#ifndef __F128FNC_H
#define __F128FNC_H

using namespace metal;

float2 two_sum(float, float);
float2 quick_two_sum(float, float);
float4 qf_add(float4, float4);
float4 qf_sub(float4, float4);
float2 split(float);
float2 two_prod(float, float);
float4 qf_mul(float4, float4);
float4 qf_mulopt(float4, float4);

#endif


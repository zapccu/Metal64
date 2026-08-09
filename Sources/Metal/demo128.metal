//
//  demo128.metal
//  Metal64
//
//  Calculate Mandelbrot set with 128 bit
//
//  Created by Dirk Braner on 12.02.26.
//

#include <metal_stdlib>

#include "f128fnc.h"

using namespace metal;

kernel void mandelbrot_qf(
    texture2d<float, access::write> outTexture [[texture(0)]],
    constant float4 *c_real_ptr [[buffer(0)]],
    constant float4 *c_imag_ptr [[buffer(1)]],
    constant float &zoom [[buffer(2)]],
    uint2 gid [[thread_position_in_grid]])
{
    float4 c_re = *c_real_ptr;
    float4 c_im = *c_imag_ptr;

    float4 z_re = float4(0.0);
    float4 z_im = float4(0.0);

    int iter = 0;
    const int max_iter = 1000;

    while (iter < max_iter) {
        float4 z_re_sq = qf_mul(z_re, z_re);
        float4 z_im_sq = qf_mul(z_im, z_im);
        
        if (z_re_sq.x + z_im_sq.x > 4.0f) break;

        // z_im = 2 * z_re * z_im + c_im
        float4 two_z_re = qf_add(z_re, z_re);
        float4 next_im = qf_add(qf_mul(two_z_re, z_im), c_im);
        
        // z_re = z_re_sq - z_im_sq + c_re
        float4 next_re = qf_add(qf_sub(z_re_sq, z_im_sq), c_re);

        z_re = next_re;
        z_im = next_im;
        iter++;
    }
    
    float4 z_re_sq = qf_mul(z_re, z_re);
    float4 z_im_sq = qf_mul(z_im, z_im);

    float color_val;

    if (iter < max_iter) {
        // Radius |z|
        float modulus_sq = z_re_sq.x + z_im_sq.x;
        
        // Smooth iteration count log(log(x))
        float smooth_iter = (float)iter + 1.0f - log2(log2(modulus_sq) * 0.5f);
        
        // Normalize to 0.0 - 1.0
        color_val = smooth_iter / (float)max_iter;
    } else {
        color_val = 0.0f;
    }

    // Cosinus colorint (blue / gold)
    float3 color = float3(
        0.5f + 0.5f * cos(3.0f + color_val * 20.0f + 0.0f), // Rot
        0.5f + 0.5f * cos(3.0f + color_val * 20.0f + 0.6f), // Grün
        0.5f + 0.5f * cos(3.0f + color_val * 20.0f + 1.0f)  // Blau
    );

    outTexture.write(float4(color, 1.0), gid);
}



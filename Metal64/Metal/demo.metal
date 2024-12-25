

//
//  demo.metal
//
//  Demonstration of 64 bit floating point and complex values
//
//  Created by Sebastian Provenzano on 12/15/21.
//

#include <metal_stdlib>
#include "c64.h"

using namespace metal;

// ==========================================================
//  Calculate Mandelbrot set, using classes c64 and f64
// ==========================================================

// Iteration results
struct MandelbrotResult {
    int iterations;
    float2 distance;
    float2 potential;
    float2 nZ;
    float4 Zn;
};

// Mandelbrot iteration with datatypes c64 / f64. About 30-50% slower than using float2 functions
MandelbrotResult iterate(c64 C, f64 bailout, int maxIter) {
    MandelbrotResult r;
    c64 Z;
    c64 D = 1.0;
    f64 nZ, aZ;
    f64 logRatio;
    f64 smoothIter;
    f64 logZn;
    r.distance = 0.0;
    r.potential = 0.0;
    r.nZ = 0.0;
    r.Zn = 0.0;
    int i;
    
    for(i=0; i <= maxIter; i++) {
        // 1st derivation of Z
        D = D * 2.0 * Z + 1.0;
        
        Z = sqr(Z) + C;
        
        nZ = norm(Z);
        if (nZ > bailout) {
            // Distance calculation
            aZ = sqrt(nZ);
            logRatio = 2.0 * log(aZ) / log(bailout);
            smoothIter = 1.0 - log(logRatio) / log2_f64;
            r.distance = (aZ * log(aZ) / norm(D) * 0.5).v;
            
            // Potential calculation
            logZn = log(nZ) / 2.0;
            r.potential = (log(logZn / log2_f64) / log2_f64).v;
            r.iterations = i;
            r.nZ = nZ.v;
            r.Zn = Z.v;
            return r;
        }
    }
    
    r.iterations = maxIter;
    r.nZ = nZ.v;
    r.Zn = Z.v;
    return r;
}

MandelbrotResult iterateFlt2(float4 C, float2 bailout, int maxIter) {
    MandelbrotResult r;
    float4 Z = 0.0;
    float4 D = float4(1.0f, 0.0f, 0.0f, 0.0f);
    float2 nZ = 0.0;
    float2 aZ = 0.0;
    float2 logRatio = 0.0f;
    float2 smoothIter = 0.0f;
    float2 logZn = 0.0f;
    r.distance = 0.0f;
    r.potential = 0.0f;
    r.nZ = 0.0f;
    r.Zn = 0.0f;
    int i;
        
    for(i=0; i <= maxIter; i++) {
        // 1st derivation of Z
        D = add_c64(mul_c64(mul_c64(D, Z), float4(2.0f, 0.0f, 0.0f, 0.0f)), float4(1.0f, 0.0f, 0.0f, 0.0f));
        
        Z = add_c64(sqr_c64(Z), C);

        nZ = norm_c64(Z);
        if (gt(nZ, bailout)) {
            // Distance calculation
            aZ = sqrt_f64(nZ);
            logRatio = 2.0 * log(aZ) / log(bailout);
            smoothIter = sub_f64(float2(1.0f, 0.0f), div_f64(logRatio, log2_f64.v));
            r.distance = mul_f64(aZ, div_f64(div_f64(log_f64(aZ), norm_c64(D)), float2(2.0f, 0.0f)));
            
            // Potential calculation
            logZn = div_f64(log_f64(nZ), float2(2.0f, 0.0f));
            r.potential = div_f64(log_f64(div_f64(logZn, log2_f64.v)), log2_f64.v);
            r.iterations = i;
            
            r.nZ = nZ;
            r.Zn = Z;
            return r;
        }
    }
    
    r.iterations = maxIter;
    r.nZ = nZ;
    r.Zn = Z;
    return r;
}

// Kernel function for Mandelbrot calculation
kernel void mandelbrot(device const float4 *C,
                       device const float2& bailout,
                       device const int& maxIter,
                       device MandelbrotResult *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains a MandelbrotResult element for each point in array C
    resultArray[index] = iterate(c64(C[index]), f64(bailout), maxIter);
    //resultArray[index] = iterateFlt2(C[index], bailout, maxIter);
}

// ==========================================================
//  Math operations on arrays using 64 bit floating point
//  functions
// ==========================================================

struct RealResult {
    f64 add;
    f64 sub;
    f64 mul;
    f64 div;
    f64 sqrt;
    f64 log;
    f64 exp;
    f64 pow;
};

// Kernel function for adding elements of 2 arrays
kernel void add_arrays(device const float2 *arr1,
                       device const float2 *arr2,
                       device const float2& val,
                       device RealResult *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    resultArray[index].add = add_f64(arr1[index], arr2[index]);
    resultArray[index].sub = sub_f64(arr1[index], arr2[index]);
    resultArray[index].mul = mul_f64(arr1[index], arr2[index]);
    resultArray[index].div = div_f64(arr1[index], arr2[index]);
    resultArray[index].sqrt = sqrt_f64(arr1[index]);
    resultArray[index].log = log_f64(arr1[index]);
    resultArray[index].exp = exp_f64(arr1[index]);
    resultArray[index].pow = pow_f64(arr1[index], arr2[index]);
}

// ==========================================================
//  Add Complex<Double> arrays by using class c64
// ==========================================================

struct ComplexResults {
    float4 add;
    float4 sub;
    float4 mul;
    float4 div;
    float4 sqr;
};

// Kernel function for adding elements of 2 complex arrays
kernel void add_complex_arrays(device const float4 *arr1,
                       device const float4 *arr2,
                       device ComplexResults *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains sum of elements of arrays arr1 and arr2
    resultArray[index].add = add_c64(arr1[index], arr2[index]);
    resultArray[index].sub = sub_c64(arr1[index], arr2[index]);
    resultArray[index].mul = mul_c64(arr1[index], arr2[index]);
    resultArray[index].div = div_c64(arr1[index], arr2[index]);
    resultArray[index].sqr = add_c64(sqr_c64(arr1[index]), arr2[index]);
}


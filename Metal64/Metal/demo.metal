

//
//  demo.metal
//
//  Demonstration of 64 bit floating point and complex values
//
//  Created by Sebastian Provenzano on 12/15/21.
//

#include <metal_stdlib>

// Include complex functions and type. Includes also real functions and type.
#include "c64.h"

using namespace metal;

// ==========================================================
//  Calculate Mandelbrot set, using classes c64 and f64
// ==========================================================

// Iteration results
struct MandelbrotResult {
    int iterations;
    f64 distance;
    f64 potential;
};

// Mandelbrot iteration
MandelbrotResult iterate(c64 C, int maxIter, f64 bailout) {
    MandelbrotResult r;
    c64 Z;
    c64 D;
    f64 nZ;
    f64 aZ;
    f64 logRatio;
    f64 smoothIter;
    f64 logZn;
    r.distance = f64(0.0);
    
    for(r.iterations=0; r.iterations <= maxIter; r.iterations++) {
        // 1st derivation of Z
        D = D * c64(2.0) * Z + c64(1.0);
        
        Z = Z * Z + C;
        
        nZ = norm(Z);
        if (nZ > bailout) {
            // Distance calculation
            aZ = sqrt(nZ);
            logRatio = f64(2.0) * log(aZ) / log(bailout);
            smoothIter = f64(1.0) - log(logRatio) / log2_f64;
            r.distance = aZ * log(aZ) / norm(D) / f64(2.0);
            
            // Potential calculation
            logZn = log(nZ) / f64(2.0);
            r.potential = log(logZn / log2_f64) / log2_f64;
        }
    }
    
    return r;
}

// Kernel function for Mandelbrot calculation
kernel void mandelbrot(device const float4 *C,
                       device const int& maxIter,
                       device const float2& bailout,
                       device MandelbrotResult *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains a MandelbrotResult element for each point in array C
    resultArray[index] = iterate(C[index], maxIter, bailout);
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
    resultArray[index].exp = exp_f64(arr1[index]);
    resultArray[index].pow = pow_f64(arr1[index], arr2[index]);
}

// ==========================================================
//  Add Complex<Double> arrays by using class c64
// ==========================================================

// Sum function, returning float4
float4 sumc64(c64 a, c64 b) {
    c64 c = a + b;
    return float4(c.r.x, c.r.y, c.i.x, c.i.y);
}

// Kernel function for adding elements of 2 complex arrays
kernel void add_complex_arrays(device const float4 *arr1,
                       device const float4 *arr2,
                       device float4 *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains sum of elements of arrays arr1 and arr2
    resultArray[index] = sumc64(c64(arr1[index]), c64(arr2[index]));
}

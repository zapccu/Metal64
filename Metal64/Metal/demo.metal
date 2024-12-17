

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
//  Mandelbrot, using class c64
// ==========================================================

// Mandelbrot iteration
int iterate(c64 C, int maxIter, f64 bailout) {
    c64 Z;
    int i = 0;
    
    while (i < maxIter && norm(Z) < bailout) {
        Z = Z * Z + C;
        i++;
    }
    
    return i;
}

// Kernel function for Mandelbrot calculation
kernel void mandelbrot(device const float4 *C,
                       device const int& maxIter,
                       device const float2& bailout,
                       device int *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains iteration count for each point in array C as 32 bit integer values
    resultArray[index] = iterate(C[index], maxIter, bailout);
}

// ==========================================================
//  Add real arrays by using 64 bit floating point functions
// ==========================================================

// Kernel function for adding elements of 2 arrays
kernel void add_arrays(device const float2 *arr1,
                       device const float2 *arr2,
                       device const float2& val,
                       device float2 *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains sum of elements of arrays arr1 and arr2
    resultArray[index] = add_f64(add_f64(arr1[index], arr2[index]), val);
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

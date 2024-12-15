

//
//  demo.metal
//
//  Demonstration of 64 bit floating point and complex values
//
//  Created by Sebastian Provenzano on 12/15/21.
//

#include <metal_stdlib>

// Include complex functions and type. Includes also real functions and type.
#include "cf64.h"

using namespace metal;

// Mandelbrot iteration
int iterate(cf64 C, int maxIter, f64 bailout) {
    cf64 Z;
    int i = 0;
    
    while (i < maxIter && norm_cf64(Z) < bailout) {
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
    // Result array contains iteration count for each point in array C
    resultArray[index] = iterate(C[index], maxIter, bailout);
}

// Kernel function for adding elements of 2 arrays
kernel void add_arrays(device const float2 *arr1,
                       device const float2 *arr2,
                       device const float2& val,
                       device float2 *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains sum of elements of arrays arr1 and arr2
    resultArray[index] = add_f64(arr1[index], arr2[index]);
}



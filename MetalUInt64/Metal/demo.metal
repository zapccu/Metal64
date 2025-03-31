

//
//  demo.metal
//
//  Demonstration of 64 bit floating point and complex values
//
//  Created by Sebastian Provenzano on 12/15/21.
//

#include <metal_stdlib>
#include "complex64.h"

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


// ==========================================================
//  Calculate Mandelbrot set, using classes complex64 and float64
// ==========================================================


// Iteration results
struct UIMandelbrotResult {
    int iterations;
    float64 distance;
    float64 potential;
    float64 nZ;
    complex64 Zn;
};

// Mandelbrot iteration with datatypes complex64 / float64
UIMandelbrotResult iterate(complex64 C, float64 bailout, int maxIter) {
    UIMandelbrotResult r;
    complex64 Z = 0.0;
    complex64 D = 1.0;
    float64 nZ, aZ;
    float64 logRatio;
    float64 smoothIter;
    float64 logZn;
    int i;
    
    for(i=0; i <= maxIter; i++) {
        // 1st derivation of Z
        D = D * 2.0 * Z + 1.0;
        
        Z = Z * Z + C;
        
        nZ = norm(Z);
        if (nZ > bailout) {
            // Distance calculation
            aZ = sqrt(nZ);
            logRatio = 2.0 * log(aZ) / log(bailout);
            smoothIter = 1.0 - log(logRatio) / FLOAT64_LOG2;
            r.distance = (aZ * log(aZ) / norm(D) * 0.5).v;
            
            // Potential calculation
            logZn = log(nZ) / 2.0;
            r.potential = (log(logZn / FLOAT64_LOG2) / FLOAT64_LOG2).v;
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
kernel void mandelbrotui(device const complex64 *C,
                       device const float64& bailout,
                       device const int& maxIter,
                       device UIMandelbrotResult *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    // Result array contains a MandelbrotResult element for each point in array C
    resultArray[index] = iterate(C[index], bailout, maxIter);
    //resultArray[index] = iterateFlt2(C[index], bailout, maxIter);
}


// ==========================================================
//  Math operations on arrays using class float64
// ==========================================================

struct Float64Result {
    float64_t add;
    float64_t sub;
    float64_t mul;
    float64_t div;
    float64_t sqrt;
    float64_t log;
    float64_t exp;
    float64_t pow;
};

// Kernel function for adding elements of 2 arrays
kernel void add_arrays_float64(device const float64_t *arr1,
                       device const float64_t *arr2,
                       device const float64_t& val,
                       device Float64Result *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    resultArray[index].add = f_add(arr1[index], arr2[index]);
    resultArray[index].sub = f_sub(arr1[index], arr2[index]);
    resultArray[index].mul = f_mul(arr1[index], arr2[index]);
    resultArray[index].div = f_div(arr1[index], arr2[index]);
    resultArray[index].sqrt = f_sqrt(arr1[index]);
    resultArray[index].log = f_log(arr1[index]);
    resultArray[index].exp = f_exp(arr1[index]);
    resultArray[index].pow = f_pow(arr1[index], arr2[index]);
}

// ==========================================================
//  Add complex64 arrays
// ==========================================================

struct UIComplexResults {
    complex64 add;
    complex64 sub;
    complex64 mul;
    complex64 div;
    complex64 sqr;
};

// Kernel function for adding elements of 2 complex arrays
kernel void add_arrays_complex64(device const complex64 *arr1,
                       device const complex64 *arr2,
                       device UIComplexResults *resultArray,
                       uint   index [[ thread_position_in_grid ]])
{
    resultArray[index].add = arr1[index] + arr2[index];
    resultArray[index].sub = arr1[index] - arr2[index];
    resultArray[index].mul = c_mul(arr1[index], arr2[index]);
    resultArray[index].div = c_div(arr1[index], arr2[index]);
    resultArray[index].sqr = c_sqr(arr1[index]);
}


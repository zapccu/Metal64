//
//  main.swift
//
//  Demo for MetalCompute class and metal64.h
//
//  Created by Dirk Braner on 15.12.24
//

import Foundation
import Metal
import ComplexModule

let log2 = log(2.0)

// Results of an iteration in Swift
struct MandelbrotResultDbl {
    var iterations: Int = 0
    var distance: Double = 0.0
    var potential: Double = 0.0
    var nZ: Double = 0.0
    var Zn: Complex<Double> = Complex<Double>(0.0, 0.0)
}

// Mandelbrot iteration for complex point C
func iterateDouble(_ C: Complex<Double>, _ maxIter: Int, _ bailout: Double) -> MandelbrotResultDbl {
    var r = MandelbrotResultDbl();
    var Z = Complex<Double>(0.0, 0.0)
    var D = Complex<Double>(0.0, 0.0)
    var nZ: Double = 0.0
    var aZ: Double = 0.0
    var logRatio: Double = 0.0
    var logZn: Double = 0.0
    
    for i in 0...maxIter {
        // 1st derivation of Z
        D = D * Complex<Double>(2.0) * Z + Complex<Double>(1.0)
        
        Z = Z * Z + C
        
        nZ = Z.lengthSquared;
        if (nZ > bailout) {
            // Distance calculation
            aZ = sqrt(nZ);
            logRatio = 2.0 * log(aZ) / log(bailout);
            _ = 1.0 - log(logRatio) / log2
            r.distance = aZ * log(aZ) / D.lengthSquared / 2.0
            
            // Potential calculation
            logZn = log(nZ) / 2.0
            r.potential = log(logZn / log2) / log2
            
            r.iterations = i
            r.nZ = nZ
            r.Zn = Z
            return r
        }
    }
    
    r.nZ = nZ
    r.Zn = Z
    r.iterations = maxIter
    return r
}

// Set number of elements to compute
var count: Int = 2000000

var timeMetal: TimeInterval = 0
var timeSwift: TimeInterval = 0
var t1: TimeInterval = 0
var t2: TimeInterval = 0

// ==========================================================
//  Real f64 operations
// ==========================================================

print("\n**** Real f64 Operations ****")

// Results
struct RealResult {
    var add: Float2 = Float2(0.0)
    var sub: Float2 = Float2(0.0)
    var mul: Float2 = Float2(0.0)
    var div: Float2 = Float2(0.0)
    var sqrt: Float2 = Float2(0.0)
    var log: Float2 = Float2(0.0)
    var exp: Float2 = Float2(0.0)
    var pow: Float2 = Float2(0.0)
}

do {
    let metalCompute = try MetalCompute("compute_float_arrays", count)
    
    // Input Array 1
    let a1: [Float2] = Array(repeating: Float2(Double.pi * 2.0), count: count)
    
    // Input Array 2
    let a2: [Float2] = Array(repeating: Float2(Double.pi), count: count)

    // Scalar value
    let x: Float2 = 1.0
    
    // Add input values for Metal computation
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)
    metalCompute.addValue(x)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(RealResult()) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nResults:")
        print("F64: \(Double(a1[0])) + \(Double(a2[0])) = \(Double(result[0].add))")
        print("DBL: \(Double.pi * 2.0) + \(Double.pi) = \(Double.pi * 2.0 + Double.pi)")
        print("F64: \(Double(a1[0])) - \(Double(a2[0])) = \(Double(result[0].sub))")
        print("DBL: \(Double.pi * 2.0) - \(Double.pi) = \(Double.pi * 2.0 - Double.pi)")
        print("F64: \(Double(a1[0])) * \(Double(a2[0])) = \(Double(result[0].mul))")
        print("DBL: \(Double.pi * 2.0) * \(Double.pi) = \(Double.pi * 2.0 * Double.pi)")
        print("F64: \(Double(a1[0])) / \(Double(a2[0])) = \(Double(result[0].div))")
        print("DBL: \(Double.pi * 2.0) / \(Double.pi) = \(Double.pi * 2.0 / Double.pi)")
        print("F64: sqrt \(Double(a1[0])) = \(Double(result[0].sqrt))")
        print("DBL: sqrt \(Double.pi * 2.0) = \(sqrt(Double.pi * 2.0))")
        print("F64: log \(Double(a1[0])) = \(Double(result[0].log))")
        print("DBL: log \(Double.pi * 2.0) = \(log(Double.pi * 2.0))")
        print("F64: exp \(Double(a1[0])) = \(Double(result[0].exp))")
        print("DBL: exp \(Double.pi * 2.0) = \(exp(Double.pi * 2.0))")
        print("F64: pow \(Double(a1[0])), \(Double(a2[0])) = \(Double(result[0].pow))")
        print("DBL: pow \(Double.pi * 2.0), \(Double.pi) = \(pow(Double.pi * 2.0, Double.pi))")
    }
    else {
        print("Compute failed")
    }
}
catch {
    print(error)
}

// Compare to native Swift Double calculation
let arr1: [Double] = Array(repeating: Double.pi * 2.0, count: count)
let arr2: [Double] = Array(repeating: Double.pi, count: count)
var arr3: [Double] = Array(repeating: 0.0, count: count)

t1 = Date().timeIntervalSince1970
for i in 0..<count {
    arr3[i] = arr1[i] + arr2[i]
    arr3[i] = arr1[i] - arr2[i]
    arr3[i] = arr1[i] * arr2[i]
    arr3[i] = arr1[i] / arr2[i]
    arr3[i] = sqrt(arr1[i])
    arr3[i] = log(arr1[i])
    arr3[i] = exp(arr1[i])
    arr3[i] = pow(arr1[i], arr2[i])
}
t2 = Date().timeIntervalSince1970
timeSwift = t2 - t1

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")

if timeSwift > timeMetal {
    print("Metal is \(timeSwift / timeMetal) times faster than Swift")
}
else {
    print("Swift is \(timeMetal / timeSwift) times faster than Metal")
}

// ==========================================================
//  Complex<Double> array operations
// ==========================================================

// Results
struct ComplexResult {
    var add: Complex2 = Complex2(0.0, 0.0)
    var sub: Complex2 = Complex2(0.0, 0.0)
    var mul: Complex2 = Complex2(0.0, 0.0)
    var div: Complex2 = Complex2(0.0, 0.0)
    var sqr: Complex2 = Complex2(0.0, 0.0)
}

print("\n**** Complex Operations ****")

do {
    let metalCompute = try MetalCompute("compute_complex_arrays", count)
    
    // Input Array 1
    let a1: [Complex2] = Array(repeating: Complex2(Double.pi, Double.pi), count: count)
    
    // Input Array 2
    let a2: [Complex2] = Array(repeating: Complex2(Double.pi, Double.pi), count: count)
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(ComplexResult()) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        let x = ComplexDouble(Double.pi, Double.pi)
        print("\nMetal results:")
        print("C64: \(ComplexDouble(a1[0])) + \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].add))")
        print("DBL: \(x) + \(x) = \(x + x)")
        print("C64: \(ComplexDouble(a1[0])) - \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].sub))")
        print("DBL: \(x) - \(x) = \(x - x)")
        print("C64: \(ComplexDouble(a1[0])) * \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].mul))")
        print("DBL: \(x) * \(x) = \(x * x)")
        print("C64: \(ComplexDouble(a1[0])) / \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].div))")
        print("DBL: \(x) / \(x) = \(x / x)")
        print("C64: sqr \(ComplexDouble(a1[0])) = \(ComplexDouble(result[0].sqr))")
        print("DBL: sqrt \(x) = \(x * x + x)")
    }
    else {
        print("Compute failed")
    }
}
catch {
    print(error)
}

// Compare to native Swift Double calculation
let carr1: [Complex<Double>] = Array(repeating: Complex<Double>(Double.pi, Double.pi), count: count)
let carr2: [Complex<Double>] = Array(repeating: Complex<Double>(Double.pi, Double.pi), count: count)
var carr3: [Complex<Double>] = Array(repeating: Complex<Double>(0.0, 0.0), count: count)

t1 = Date().timeIntervalSince1970
for i in 0..<count {
    carr3[i] = carr1[i] + carr2[i]
    carr3[i] = carr1[i] - carr2[i]
    carr3[i] = carr1[i] * carr2[i]
    carr3[i] = carr1[i] / carr2[i]
    carr3[i] = carr1[i] * carr1[i]
}
print("\nSwift results:")
for i in 0..<3 {
    print("\(carr3[i])")
}
t2 = Date().timeIntervalSince1970
timeSwift = t2 - t1

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")

if timeSwift > timeMetal {
    print("Metal is \(timeSwift / timeMetal) times faster than Swift")
}
else {
    print("Swift is \(timeMetal / timeSwift) times faster than Metal")
}

// ==========================================================
//  Mandelbrot with f64 / c64
// ==========================================================

print("\n**** Mandelbrot ****")

// Results of an iteration in Metal
struct MandelbrotResult {
    var iterations: Int32
    var distance: Float2
    var potential: Float2
    var nZ: Float2
    var Zn: Complex2
}

let width: Int = 1024
let height: Int = 1024
count = width * height
let dx: Double = 3.0 / Double(width)
let dy: Double = 3.0 / Double(height)
var maxIter: Int32 = 500
let bailout: Float2 = Float2(4.0)

// Swift calculation
print("\nSwift results:")
t1 = Date().timeIntervalSince1970
var n: Int = 0
for y in 0..<height {
    let y0: Double = -1.5 + dy * Double(y)
    for x in 0..<width {
        let x0: Double = -2.5 + dx * Double(x)
        let r = iterateDouble(Complex<Double>(x0, y0), Int(maxIter), 4.0)
        if y == 500 && x >= 500 && x < 503 {
            print("\(Complex<Double>(x0, y0)): i=\(r.iterations), d=\(r.distance), p=\(r.potential), n=\(r.nZ), Zn=\(ComplexDouble(r.Zn))")
        }
    }
}
t2 = Date().timeIntervalSince1970
timeSwift = t2 - t1

// Init a flat array with complex points
var C: [Complex2] = Array(repeating: Complex2(0.0, 0.0), count: width * height)
for y in 0..<height {
    let y0: Double = -1.5 + dy * Double(y)
    for x in 0..<width {
        let x0: Double = -2.5 + dx * Double(x)
        C[y * width + x] = Complex2(x0, y0)
    }
}

do {
    let metalCompute = try MetalCompute("mandelbrot", count)

    try metalCompute.addBuffer(C)
    metalCompute.addValue(bailout)
    metalCompute.addValue(maxIter)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(MandelbrotResult(iterations: Int32(0), distance: 0.0, potential: 0.0, nZ: 0.0, Zn: Complex2(0.0, 0.0))) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        let offset = 500 * width + 500
        for i in 0..<3 {
            print("\(Complex<Double>(C[i+offset])): i=\(result[i+offset].iterations), d=\(Double(result[i+offset].distance)), p=\(Double(result[i+offset].potential)), n=\(Double(result[i+offset].nZ)), Zn=\(ComplexDouble(result[i+offset].Zn))")
        }
    }
    else {
        print("Compute failed")
    }
}

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")

if timeSwift > timeMetal {
    print("Metal is \(timeSwift / timeMetal) times faster than Swift")
}
else {
    print("Swift is \(timeMetal / timeSwift) times faster than Metal")
}

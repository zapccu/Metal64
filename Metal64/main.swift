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

// Mandelbrot iteration for complex point C
func iterateDouble(_ C: Complex<Double>, _ maxIter: Int, _ bailout: Double) -> Int {
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
            _ = aZ * log(aZ) / D.lengthSquared / 2.0
            
            // Potential calculation
            logZn = log(nZ) / 2.0
            _ = log(logZn / log2) / log2
            
            return i
        }
    }
    
    return maxIter
}

// Set number of elements to compute
var count: Int = 200000

var timeMetal: TimeInterval = 0
var timeSwift: TimeInterval = 0
var t1: TimeInterval = 0
var t2: TimeInterval = 0

// ==========================================================
//  Math operations
// ==========================================================

print("\n**** Real Operations ****")

// Results
struct RealResult {
    var add: Float2 = Float2(0.0)
    var sub: Float2 = Float2(0.0)
    var mul: Float2 = Float2(0.0)
    var div: Float2 = Float2(0.0)
    var sqrt: Float2 = Float2(0.0)
    var exp: Float2 = Float2(0.0)
    var pow: Float2 = Float2(0.0)
}

do {
    let metalCompute = try MetalCompute("add_arrays")
    
    // Input Array 1
    let a1: [Float2] = Array(repeating: Float2(Double.pi * 2.0), count: count)
    
    // Input Array 2
    let a2: [Float2] = Array(repeating: Float2(Double.pi), count: count)

    // Scalar value
    let x: Float2 = 1.0
    
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
    arr3[i] = arr1[i] + arr2[i] + 1.0
}
t2 = Date().timeIntervalSince1970
timeSwift = t2 - t1

var timeFactor = timeSwift / timeMetal

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")
if timeFactor > 1 {
    print("Metal is \(timeFactor) times faster than Swift")
}
else {
    print("Swift is \(timeFactor) times faster than Metal")
}

// ==========================================================
//  Add Complex<Double> arrays
// ==========================================================

print("\n**** Add Complex<Double> Arrays ****")

do {
    let metalCompute = try MetalCompute("add_complex_arrays")
    
    // Input Array 1
    let a1: [Complex2] = Array(repeating: Complex2(Double.pi, Double.pi), count: count)
    
    // Input Array 2
    let a2: [Complex2] = Array(repeating: Complex2(Double.pi, Double.pi), count: count)
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(Complex2(0.0, 0.0)) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        for i in 0..<3 {
            print("\(Complex<Double>(result[i]))")
        }
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
}
print("\nSwift results:")
for i in 0..<3 {
    print("\(carr3[i])")
}
t2 = Date().timeIntervalSince1970
timeSwift = t2 - t1

timeFactor = timeSwift / timeMetal

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")
if timeFactor > 1 {
    print("Metal is \(timeFactor) times faster than Swift")
}
else {
    print("Swift is \(timeFactor) times faster than Metal")
}

// ==========================================================
//  Mandelbrot
// ==========================================================

print("\n**** Mandelbrot ****")

// Results of an iteration
struct MandelbrotResult {
    var iterations: Int32
    var distance: Float2
    var potential: Float2
}

let width: Int = 1024
let height: Int = 1024
count = width * height
let dx: Double = 3.0 / Double(width)
let dy: Double = 3.0 / Double(height)
let maxIter: Int32 = 500
let bailout: Float2 = Float2(4.0)

// Swift calculation
print("\nSwift results:")
t1 = Date().timeIntervalSince1970
var n: Int = 0
var r: Int = 0
for y in 0..<height {
    let y0: Double = -1.5 + dy * Double(y)
    for x in 0..<width {
        let x0: Double = -2.5 + dx * Double(x)
        r = iterateDouble(Complex<Double>(x0, y0), Int(maxIter), 4.0)
        if y == 500 && x >= 500 && x < 503 {
            print("\(Complex<Double>(x0, y0)) = \(r)")
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
    let metalCompute = try MetalCompute("mandelbrot")

    try metalCompute.addBuffer(C)
    metalCompute.addValue(maxIter)
    metalCompute.addValue(bailout)
    
    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(MandelbrotResult(iterations: Int32(0), distance: 0.0, potential: 0.0)) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        let offset = 500 * width + 500
        for i in 0..<3 {
            print("\(Complex<Double>(C[i+offset])) = \(result[i+offset].iterations), \(Double(result[i+offset].distance))")
        }
    }
    else {
        print("Compute failed")
    }
}

timeFactor = timeSwift / timeMetal

print("\nTime Metal for \(count) elements: \(timeMetal)")
print("Time Swift for \(count) elements: \(timeSwift)")
if timeFactor > 1 {
    print("Metal is \(timeFactor) times faster than Swift")
}
else {
    print("Swift is \(timeFactor) times faster than Metal")
}


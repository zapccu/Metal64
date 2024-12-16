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

// Mandelbrot iteration for complex point C
func iterateDouble(_ C: Complex<Double>, _ maxIter: Int32, _ bailout: Double) -> Int {
    var Z = Complex<Double>(0.0, 0.0)
    var i: Int = 0
    
    while (i < maxIter && Z.real * Z.real + Z.imaginary * Z.imaginary < bailout) {
        Z = Z * Z + C
        i += 1
    }
    
    return i
}

// Set number of elements to compute
var count: Int = 200000

var timeMetal: TimeInterval = 0
var timeSwift: TimeInterval = 0
var t1: TimeInterval = 0
var t2: TimeInterval = 0

// ==========================================================
//  Add Double arrays
// ==========================================================

print("\n**** Add Double Arrays ****")

do {
    let metalCompute = try MetalCompute("add_arrays")
    
    // Input Array 1
    let a1: [Float2] = Array(repeating: Float2(Double.pi), count: count)
    
    // Input Array 2
    let a2: [Float2] = Array(repeating: Float2(Double.pi), count: count)

    // Scalar value
    let x: Float2 = 1.0
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)
    metalCompute.addValue(x)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(Float2()) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        for i in 0..<3 {
            print("\(result[i].x) \(result[i].y) = \(Double(result[i]))")
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
let arr1: [Double] = Array(repeating: Double.pi, count: count)
let arr2: [Double] = Array(repeating: Double.pi, count: count)
var arr3: [Double] = Array(repeating: 0.0, count: count)

t1 = Date().timeIntervalSince1970
for i in 0..<count {
    arr3[i] = arr1[i] + arr2[i] + 1.0
}
print("\nSwift results:")
for i in 0..<3 {
    print("\(arr3[i])")
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
        r = iterateDouble(Complex<Double>(x0, y0), maxIter, 4.0)
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
    if let result = metalCompute.compute(Int32(0)) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        let offset = 500 * width + 500
        for i in 0..<3 {
            print("\(Complex<Double>(C[i+offset])) = \(result[i+offset])")
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


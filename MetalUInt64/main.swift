//
//  main.swift
//
//
//  Created by Dirk Braner on 15.12.24
//

import Foundation
import Metal
import ComplexModule

let log2 = log(2.0)
let l2: FltUint64 = FltUint64(log2)
print("log2=", l2)
print("log2=", log(2.0))
print("log2=", Double(l2))

let pi = Double.pi
let pi2: FltUint64 = FltUint64(pi)
print("pi=", pi2)
print("pi=", Double.pi)
print("pi=", Double(bitPattern: pi2))

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
var count: Int = 200000

var timeMetal: TimeInterval = 0
var timeSwift: TimeInterval = 0
var t1: TimeInterval = 0
var t2: TimeInterval = 0


// ==========================================================
//  Real float64 operations
// ==========================================================

print("\n**** Real Float64 Operations ****")

// Results
struct UIRealResult {
    var add: FltUint64 = FltUint64(0.0)
    var sub: FltUint64 = FltUint64(0.0)
    var mul: FltUint64 = FltUint64(0.0)
    var div: FltUint64 = FltUint64(0.0)
    var sqrt: FltUint64 = FltUint64(0.0)
    var log: FltUint64 = FltUint64(0.0)
    var exp: FltUint64 = FltUint64(0.0)
    var pow: FltUint64 = FltUint64(0.0)
}

do {
    let metalCompute = try MetalCompute("add_arrays_float64", count)
    
    // Input Array 1
    let a1: [FltUint64] = Array(repeating: FltUint64(Double.pi * 2.0), count: count)
    
    // Input Array 2
    let a2: [FltUint64] = Array(repeating: FltUint64(Double.pi), count: count)

    // Scalar value
    let x: FltUint64 = FltUint64(1.0)
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)
    metalCompute.addValue(x)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(UIRealResult()) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nResults:")
        print("float64: \(Double(fltuint64: a1[0])) + \(Double(fltuint64: a2[0])) = \(Double(fltuint64: result[0].add))")
        print("double : \(Double.pi * 2.0) + \(Double.pi) = \(Double.pi * 2.0 + Double.pi)")
        print("float64: \(Double(fltuint64: a1[0])) - \(Double(fltuint64: a2[0])) = \(Double(fltuint64: result[0].sub))")
        print("double : \(Double.pi * 2.0) - \(Double.pi) = \(Double.pi * 2.0 - Double.pi)")
        print("float64: \(Double(fltuint64: a1[0])) * \(Double(fltuint64: a2[0])) = \(Double(fltuint64: result[0].mul))")
        print("double : \(Double.pi * 2.0) * \(Double.pi) = \(Double.pi * 2.0 * Double.pi)")
        print("float64: \(Double(fltuint64: a1[0])) / \(Double(fltuint64: a2[0])) = \(Double(fltuint64: result[0].div))")
        print("double : \(Double.pi * 2.0) / \(Double.pi) = \(Double.pi * 2.0 / Double.pi)")
        print("float64: sqrt \(Double(fltuint64: a1[0])) = \(Double(fltuint64: result[0].sqrt))")
        print("double : sqrt \(Double.pi * 2.0) = \(sqrt(Double.pi * 2.0))")
        print("float64: log \(Double(fltuint64: a1[0])) = \(Double(fltuint64: result[0].log))")
        print("double : log \(Double.pi * 2.0) = \(log(Double.pi * 2.0))")
        print("float64: exp \(Double(fltuint64: a1[0])) = \(Double(fltuint64: result[0].exp))")
        print("double : exp \(Double.pi * 2.0) = \(exp(Double.pi * 2.0))")
        print("float64: pow \(Double(fltuint64: a1[0])), \(Double(fltuint64: a2[0])) = \(Double(fltuint64: result[0].pow))")
        print("double : pow \(Double.pi * 2.0), \(Double.pi) = \(pow(Double.pi * 2.0, Double.pi))")
    }
    else {
        print("Compute failed")
    }
}
catch {
    print(error)
}

print("\nTime Metal for \(count) elements: \(timeMetal)")

// ==========================================================
//  Complex64 array operations
// ==========================================================

// Results
struct UIComplexResult {
    var add: CplxUint64 = CplxUint64(0.0, 0.0)
    var sub: CplxUint64 = CplxUint64(0.0, 0.0)
    var mul: CplxUint64 = CplxUint64(0.0, 0.0)
    var div: CplxUint64 = CplxUint64(0.0, 0.0)
    var sqr: CplxUint64 = CplxUint64(0.0, 0.0)
}

print("\n**** complex64 Operations ****")

do {
    let metalCompute = try MetalCompute("add_arrays_complex64", count)
    
    // Input Array 1
    let a1: [CplxUint64] = Array(repeating: CplxUint64(Double.pi, Double.pi), count: count)
    
    // Input Array 2
    let a2: [CplxUint64] = Array(repeating: CplxUint64(Double.pi, Double.pi), count: count)
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(UIComplexResult()) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1

        let x = ComplexDouble(Double.pi, Double.pi)
        print("\nMetal results:")
        print("complex64: \(ComplexDouble(a1[0])) + \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].add))")
        print("DBL      : \(x) + \(x) = \(x + x)")
        print("complex64: \(ComplexDouble(a1[0])) - \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].sub))")
        print("DBL      : \(x) - \(x) = \(x - x)")
        print("complex64: \(ComplexDouble(a1[0])) * \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].mul))")
        print("DBL      : \(x) * \(x) = \(x * x)")
        print("complex64: \(ComplexDouble(a1[0])) / \(ComplexDouble(a2[0])) = \(ComplexDouble(result[0].div))")
        print("DBL      : \(x) / \(x) = \(x / x)")
        print("complex64: sqr \(ComplexDouble(a1[0])) = \(ComplexDouble(result[0].sqr))")
        print("DBL      : sqr \(x) = \(x * x)")
    }
    else {
        print("Compute failed")
    }
}
catch {
    print(error)
}

print("\nTime Metal for \(count) elements: \(timeMetal)")

//exit(0)

// ==========================================================
//  Mandelbrot with FltUint64 / CplxUint64
// ==========================================================

print("\n**** Mandelbrot FltUint64 / CplxUint64 ****")

let width: Int = 1024
let height: Int = 1024
count = width * height
let dx: Double = 3.0 / Double(width)
let dy: Double = 3.0 / Double(height)
var maxIter: Int32 = 500

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

// Results of an iteration in Metal
struct UIMandelbrotResult {
    var iterations: Int32
    var distance: FltUint64
    var potential: FltUint64
    var nZ: FltUint64
    var Zn: CplxUint64
}

let bailout2: FltUint64 = FltUint64(4.0)

// Init a flat array with complex points
var C1: [CplxUint64] = Array(repeating: CplxUint64(0.0, 0.0), count: width * height)
for y in 0..<height {
    let y0: Double = -1.5 + dy * Double(y)
    for x in 0..<width {
        let x0: Double = -2.5 + dx * Double(x)
        C1[y * width + x] = CplxUint64(x0, y0)
    }
}

do {
    let metalCompute = try MetalCompute("mandelbrotui", count)

    try metalCompute.addBuffer(C1)
    metalCompute.addValue(bailout2)
    metalCompute.addValue(maxIter)

    t1 = Date().timeIntervalSince1970
    
    // Compute and show first 3 results
    if let result = metalCompute.compute(UIMandelbrotResult(iterations: Int32(0), distance: FltUint64(0.0), potential: FltUint64(0.0), nZ: FltUint64(0.0), Zn: CplxUint64(0.0, 0.0))) {
        t2 = Date().timeIntervalSince1970
        timeMetal = t2 - t1
        
        print("\nMetal results:")
        let offset = 500 * width + 500
        for i in 0..<3 {
            print("\(Complex<Double>(C1[i+offset])): i=\(result[i+offset].iterations), d=\(Double(fltuint64: result[i+offset].distance)), p=\(Double(fltuint64: result[i+offset].potential)), n=\(Double(fltuint64: result[i+offset].nZ)), Zn=\(ComplexDouble(result[i+offset].Zn))")
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



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
import simd

let log2 = log(2.0)

// Results of an iteration in Swift
struct MandelbrotResultDbl {
    var iterations: Int = 0
    var distance: Double = 0.0
    var potential: Double = 0.0
    var nZ: Double = 0.0
    var Zn: Complex<Double> = Complex<Double>(0.0, 0.0)
}

func generateFloat2() {
    let pot: [Double] = [
        1.0,
        0.5,
        0.25,
        0.125,
        0.0625,
        0.03125,
        0.015625,
        0.0078125,
        0.00390625,
        0.001953125,
        0.0009765625,
        0.00048828125,
        0.000244140625,
        0.0001220703125,
        6.103515625e-05,
        3.0517578125e-05,
        1.52587890625e-05,
        7.62939453125e-06,
        3.814697265625e-06,
        1.9073486328125e-06,
        9.5367431640625e-07,
        4.76837158203125e-07,
        2.384185791015625e-07,
        1.1920928955078125e-07,
        5.960464477539063e-08,
        2.9802322387695312e-08,
        1.4901161193847656e-08,
        7.450580596923828e-09,
        3.725290298461914e-09,
        1.862645149230957e-09,
        9.313225746154785e-10,
        4.656612873077393e-10,
        2.3283064365386963e-10,
        1.1641532182693481e-10,
        5.820766091346741e-11,
        2.9103830456733704e-11,
        1.4551915228366852e-11,
        7.275957614183426e-12,
        3.637978807091713e-12,
        1.8189894035458565e-12,
        9.094947017729282e-13,
        4.547473508864641e-13,
        2.2737367544323206e-13,
        1.1368683772161603e-13,
        5.684341886080802e-14,
        2.842170943040401e-14,
        1.4210854715202004e-14,
        7.105427357601002e-15,
        3.552713678800501e-15
    ]
    
    let angles: [Double] = [
        7.8539816339744830962E-01,
        4.6364760900080611621E-01,
        2.4497866312686415417E-01,
        1.2435499454676143503E-01,
        6.2418809995957348474E-02,
        3.1239833430268276254E-02,
        1.5623728620476830803E-02,
        7.8123410601011112965E-03,
        3.9062301319669718276E-03,
        1.9531225164788186851E-03,
        9.7656218955931943040E-04,
        4.8828121119489827547E-04,
        2.4414062014936176402E-04,
        1.2207031189367020424E-04,
        6.1035156174208775022E-05,
        3.0517578115526096862E-05,
        1.5258789061315762107E-05,
        7.6293945311019702634E-06,
        3.8146972656064962829E-06,
        1.9073486328101870354E-06,
        9.5367431640596087942E-07,
        4.7683715820308885993E-07,
        2.3841857910155798249E-07,
        1.1920928955078068531E-07,
        5.9604644775390554414E-08,
        2.9802322387695303677E-08,
        1.4901161193847655147E-08,
        7.4505805969238279871E-09,
        3.7252902984619140453E-09,
        1.8626451492309570291E-09,
        9.3132257461547851536E-10,
        4.6566128730773925778E-10,
        2.3283064365386962890E-10,
        1.1641532182693481445E-10,
        5.8207660913467407226E-11,
        2.9103830456733703613E-11,
        1.4551915228366851807E-11,
        7.2759576141834259033E-12,
        3.6379788070917129517E-12,
        1.8189894035458564758E-12,
        9.0949470177292823792E-13,
        4.5474735088646411896E-13,
        2.2737367544323205948E-13,
        1.1368683772161602974E-13,
        5.6843418860808014870E-14,
        2.8421709430404007435E-14,
        1.4210854715202003717E-14,
        7.1054273576010018587E-15,
        3.5527136788005009294E-15,
        1.7763568394002504647E-15,
        8.8817841970012523234E-16,
        4.4408920985006261617E-16,
        2.2204460492503130808E-16,
        1.1102230246251565404E-16,
        5.5511151231257827021E-17,
        2.7755575615628913511E-17,
        1.3877787807814456755E-17,
        6.9388939039072283776E-18,
        3.4694469519536141888E-18,
        1.7347234759768070944E-18
    ]

    let kprod: [Double] = [
        0.70710678118654752440,
        0.63245553203367586640,
        0.61357199107789634961,
        0.60883391251775242102,
        0.60764825625616820093,
        0.60735177014129595905,
        0.60727764409352599905,
        0.60725911229889273006,
        0.60725447933256232972,
        0.60725332108987516334,
        0.60725303152913433540,
        0.60725295913894481363,
        0.60725294104139716351,
        0.60725293651701023413,
        0.60725293538591350073,
        0.60725293510313931731,
        0.60725293503244577146,
        0.60725293501477238499,
        0.60725293501035403837,
        0.60725293500924945172,
        0.60725293500897330506,
        0.60725293500890426839,
        0.60725293500888700922,
        0.60725293500888269443,
        0.60725293500888161574,
        0.60725293500888134606,
        0.60725293500888127864,
        0.60725293500888126179,
        0.60725293500888125757,
        0.60725293500888125652,
        0.60725293500888125626,
        0.60725293500888125619,
        0.60725293500888125617
    ]
    
    let fx_vec: [Double] = [
        1.6487212707001282,
        1.2840254166877414,
        1.1331484530668263,
        1.0644944589178593,
        1.0317434074991028,
        1.0157477085866857,
        1.007843097206448,
        1.0039138893383475,
        1.0019550335910028,
        1.0009770394924165,
        1.0004884004786945,
        1.0002441704297478,
        1.0001220777633837,
        1.0000610370189331,
        1.000030518043791,
        1.0000152589054785,
        1.000007629423635,
        1.0000038147045416,
        1.0000019073504518,
        1.0000009536747712,
        1.000000476837272,
        1.0000002384186075,
        1.0000001192092967,
        1.0000000596046466,
        1.0000000298023228,
        1.0000000149011612,
        1.0000000074505806,
        1.0000000037252903,
        1.0000000018626451
    ]
    
    for i in pot {
        let x = Float2(i)
        print("float2(\(x.x), \(x.y)),")
    }
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
        D = (D + D) * Z + Complex<Double>(1.0)

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
    var fmod: Float2 = Float2(0.0)
    var sqrt: Float2 = Float2(0.0)
    var log: Float2 = Float2(0.0)
    var exp: Float2 = Float2(0.0)
    var pow: Float2 = Float2(0.0)
    var sine: Float2 = Float2(0.0)
    var cosine: Float2 = Float2(0.0)
    var tangent: Float2 = Float2(0.0)
    var asine: Float2 = Float2(0.0)
    var acosine : Float2 = Float2(0.0)
    var atangent: Float2 = Float2(0.0)
    var atangent2: Float2 = Float2(0.0)
}

do {
    let metalCompute = try MetalCompute("compute_float_arrays", count)
    
    // Input Array 1
    let a1: [Float2] = Array(repeating: 7.5, count: count)
    
    // Input Array 2
    let a2: [Float2] = Array(repeating: 3.3, count: count)
    
    let a0: Double = 7.5
    let a01: Double = 3.3

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
        print("DBL: \(a0) + \(a01) = \(a0 + a01)")
        print("F64: \(Double(a1[0])) - \(Double(a2[0])) = \(Double(result[0].sub))")
        print("DBL: \(a0) - \(a01) = \(a0 - a01)")
        print("F64: \(Double(a1[0])) * \(Double(a2[0])) = \(Double(result[0].mul))")
        print("DBL: \(a0) * \(a01) = \(a0 * a01)")
        print("F64: \(Double(a1[0])) / \(Double(a2[0])) = \(Double(result[0].div))")
        print("DBL: \(a0) / \(a01) = \(a0 / a01)")
        print("F64: fmod \(Double(a1[0])),\(Double(a2[0])) = \(Double(result[0].fmod))")
        print("DBL: fmod \(a0),\(a01) = \(fmod(a0, a01))")
        print("F64: sqrt \(Double(a1[0])) = \(Double(result[0].sqrt))")
        print("DBL: sqrt \(a0) = \(sqrt(a0))")
        print("F64: log \(Double(a1[0])) = \(Double(result[0].log))")
        print("DBL: log \(a0) = \(log(a0))")
        print("F64: exp \(Double(a1[0])) = \(Double(result[0].exp))")
        print("DBL: exp \(a0) = \(exp(a0))")
        print("F64: pow \(Double(a1[0])), \(Double(a2[0])) = \(Double(result[0].pow))")
        print("DBL: pow \(a0), \(a01) = \(pow(a0, a01))")
        print("F64: sin \(Double(a1[0])) = \(Double(result[0].sine))")
        print("DBL: sin \(a0) = \(sin(a0))")
        print("F64: cos \(Double(a1[0])) = \(Double(result[0].cosine))")
        print("DBL: cos \(a0) = \(cos(a0))")
        print("F64: tan \(Double(a1[0])) = \(Double(result[0].tangent))")
        print("DBL: tan \(a0) = \(tan(a0))")
        print("F64: asin \(sin(Double(a1[0]))) = \(Double(result[0].asine))")
        print("DBL: asin \(sin(a0)) = \(asin(sin(a0)))")
        print("F64: acos \(cos(Double(a1[0]))) = \(Double(result[0].acosine))")
        print("DBL: acos \(cos(a0)) = \(acos(cos(a0)))")
        print("F64: atan \(tan(Double(a1[0]))) = \(Double(result[0].atangent))")
        print("DBL: atan \(tan(a0)) = \(atan(tan(a0)))")
        print("F64: atan2 \(Double(a1[0])),\(Double(a1[0])) = \(Double(result[0].atangent2))")
        print("DBL: atan2 \(a0),\(a0) = \(atan2(a0, a0))")
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
    arr3[i] = sin(arr1[i])
    arr3[i] = cos(arr1[i])
    arr3[i] = tan(arr1[i])
    arr3[i] = asin(sin(arr1[i]))
    arr3[i] = acos(cos(arr1[i]))
    arr3[i] = atan(tan(arr1[i]))
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

print(Float2(1.0/Double.pi))
// print(floor(Float2(-0.5,-1.2)))
// generateFloat2()

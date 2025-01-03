//
//  Complex2.swift
//
//  Part of Metal64
//
//  Implementation of type Complex2 as representation of 2x64 bit Complex
//
//  Created by Dirk Braner on 15.12.24.
//
//  Requires package swift-numerics
//

// Import ComplexModule from swift-numerics
import ComplexModule

/// Datatype for 2x64 bit Metal complex floating point values
typealias Complex2 = SIMD4<Float32>

/// Datatype for double precision complex values
typealias ComplexDouble = Complex<Float64>

extension Complex<Float64> {

    /// Convert Complex2 to ComplexDouble
    init(_ complex2: Complex2) {
        self.init(
            Double(Float2(complex2.x, complex2.y)),
            Double(Float2(complex2.z, complex2.w))
        )
    }
}

// Extend SIMD4 to support conversion of float / double datatypes to Complex2
extension SIMD4<Float32>: @retroactive ExpressibleByFloatLiteral {
    
    /// Convert real and imaginary part from Double to Complex2
    init(_ real: Double = 0.0, _ imag: Double = 0.0) {
        let r = real == 0.0 ? 0.0 : Float2(real)
        let i = imag == 0.0 ? 0.0 : Float2(imag)
        self.init(x: r.x, y: r.y, z: i.x, w: i.y)
    }
    
    /// Convert ComplexDouble to Complex2
    init (_ number: ComplexDouble) {
        self.init(number.real, number.imaginary)
    }
    
    /// Convert Float2 to Complex2
    init(_ number: Float2) {
        self.init(x: number.x, y: number.y, z: 0.0, w: 0.0)
    }
    
    /// Convert Int to Complex2
    init(_ number: Int) {
        self.init(Float2(Double(number)))
    }
    
    /// Assign Double value to Complex2
    public init(floatLiteral number: Double) {
        self.init(number)
    }
}

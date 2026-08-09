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

// Import modules from swift-numerics
import RealModule
import ComplexModule

/// Datatype for 2x64 bit Metal complex floating point values
public typealias Complex2 = SIMD4<Float32>

/// Datatype for double precision complex values
public typealias ComplexDouble = Complex<Float64>

extension Complex<Float64> {

    /// Convert Complex2 to ComplexDouble
    public init(_ complex2: Complex2) {
        self.init(
            Double(Float2(complex2.x, complex2.y)),
            Double(Float2(complex2.z, complex2.w))
        )
    }
    
    public func square() -> Complex<Float64> {
        let realPart = self.real * self.real - self.imaginary * self.imaginary
        let imaginaryPart = 2.0 * self.real * self.imaginary
        return Complex<Float64>(realPart, imaginaryPart)
    }
}

// Extend SIMD4 to support conversion of float / double datatypes to Complex2
extension SIMD4<Float32>: @retroactive ExpressibleByFloatLiteral {

    /// Access real part
    public var real: Float2 {
        get { Float2(x, y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
    
    /// Access imaginary part
    public var imaginary: Float2 {
        get { Float2(z, w) }
        set {
            z = newValue.x
            w = newValue.y
        }
    }
        
    /// Convert real and imaginary part from Float2 to Complex2
    public init(_ real: Float2, _ imaginary: Float2) {
        self.init(x: real.x, y: real.y, z: imaginary.x, w: imaginary.y)
    }

    /// Convert real and imaginary part from Double to Complex2
    public init(_ real: Double = 0.0, _ imag: Double = 0.0) {
        let r = real == 0.0 ? 0.0 : Float2(real)
        let i = imag == 0.0 ? 0.0 : Float2(imag)
        self.init(x: r.x, y: r.y, z: i.x, w: i.y)
    }
    
    /// Convert ComplexDouble to Complex2
    public init (_ number: ComplexDouble) {
        self.init(number.real, number.imaginary)
    }
    
    /// Convert Float2 to Complex2
    public init(_ number: Float2) {
        self.init(x: number.x, y: number.y, z: 0.0, w: 0.0)
    }
    
    /// Convert Int to Complex2
    public init(_ number: Int) {
        self.init(Float2(Double(number)))
    }
    
    /// Assign Double value to Complex2
    public init(floatLiteral number: Double) {
        self.init(number)
    }
}

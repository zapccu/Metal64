//
//  CplxUint64.swift
//  Metal64
//
//  Created by Dirk Braner on 01.01.25.
//

// Import ComplexModule from swift-numerics
import ComplexModule

typealias ComplexDouble = Complex<Float64>

extension Complex<Float64> {

    /// Convert Complex2 to ComplexDouble
    init(_ complex64: CplxUint64) {
        self.init(
            Double(fltuint64: complex64.x),
            Double(fltuint64: complex64.y)
        )
    }
}

// extension SIMD2<FltUint64> {
struct CplxUint64 {
    var x: FltUint64 = 0
    var y: FltUint64 = 0

    /// Convert real and imaginary part from Double to CplxUint64
    init(_ real: Double = 0.0, _ imag: Double = 0.0) {
        self.init(FltUint64(real), FltUint64(imag))
    }
    
    /// Convert real and imaginary part from FltUint64 to CplxUint64
    init(_ real: FltUint64 = 0, _ imag: FltUint64 = 0) {
        //self.init(x: real, y: imag)
        x = real
        y = imag
    }
    
    /// Convert ComplexDouble to Complex2
    init (_ number: ComplexDouble) {
        self.init(number.real, number.imaginary)
    }
    
    /// Convert Int to Complex2
    init(_ number: Int) {
        self.init(Double(number))
    }
}


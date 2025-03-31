//
//  Float2.swift
//
//  Part of Metal64
//
//  Implementation of type Float2
//
//  Created by Dirk Braner on 15.12.24.
//

/// Datatypes for 64 bit Metal floating point values
typealias Float2 = SIMD2<Float32>

extension Double {
    
    /// Convert Float2 to Double
    init(_ float2: Float2) {
        self = Double(float2.x) + Double(float2.y)
    }
}

extension SIMD2<Float32>: @retroactive ExpressibleByFloatLiteral {
    
    /// Convert Double to Float2
    init(_ number: Double = 0.0) {
        var hi: Float32 = 0.0
        var lo: Float32 = 0.0
        
        if number != 0.0 {
            let splitter = Double((1 << 29) + 1)
            let t = number * splitter
            hi = Float32(t - (t - number))
            lo = Float32(number - Double(hi))
        }
        
        self.init(x: hi, y: lo)
    }
    
    /// Convert Float to Float2
    init(_ number: Float) {
        self.init(x: number, y: 0.0)
    }
    
    /// Convert Int to Float2
    init(_ number: Int) {
        self.init(Float(number))
    }
    
    /// Assign Double value to Float2
    public init(floatLiteral number: Double) {
        self.init(number)
    }
}

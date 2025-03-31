//
//  FltUint64.swift
//  Metal64
//
//  Created by Dirk Braner on 01.01.25.
//

typealias FltUint64 = UInt64

extension Double {
    
    /// Convert Float64 to Double
    init(fltuint64: FltUint64) {
        self = Double(bitPattern: fltuint64)
    }
}

extension UInt64 {
    
    // Convert Double to FltUint64
    init(_ double: Double) {
        self = double.bitPattern
    }
    
    /// Assign Double value to FltUint64
    public init(floatLiteral number: Double) {
        self.init(number)
    }
}

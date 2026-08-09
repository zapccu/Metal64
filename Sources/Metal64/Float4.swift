//
//  Float4.swift
//  Metal64
//
//  Created by Dirk Braner on 12.02.26.
//

import Foundation

extension SIMD4<Float32> {
    
    /// Convert a high precision String to float4 (emulate 128-bit Float)
    init(_ numericString: String) {
        // Use Decimal for high precision parsing
        guard let decimalValue = Decimal(string: numericString) else {
            self.init(0, 0, 0, 0)
            return
        }
        
        var remaining = decimalValue
        
        // Extract high part
        let f1 = Float32(truncating: remaining as NSNumber)
        remaining -= Decimal(Double(f1))
        
        // Extract rest
        let f2 = Float32(truncating: remaining as NSNumber)
        remaining -= Decimal(Double(f2))
        
        // Extract rest
        let f3 = Float32(truncating: remaining as NSNumber)
        remaining -= Decimal(Double(f3))
        
        // Extract rest (low)
        let f4 = Float32(truncating: remaining as NSNumber)
        
        self.init(f1, f2, f3, f4)
    }
}

func prepareMandelbrotParams(center: (re: String, im: String), zoom: Decimal, width: Int, height: Int) -> (startRe: SIMD4<Float32>, startIm: SIMD4<Float32>, delta: SIMD4<Float32>) {
    
    let decCenterRe = Decimal(string: center.re)!
    let decCenterIm = Decimal(string: center.im)!
    
    // Berechne die Sichtbereich-Breite basierend auf dem Zoom
    let viewWidth = Decimal(4.0) / zoom
    let viewHeight = viewWidth * Decimal(height) / Decimal(width)
    
    // Delta pro Pixel (Schrittweite)
    let decDelta = viewWidth / Decimal(width)
    
    // Startpunkt oben links (Center - halbe Breite/Höhe)
    let decStartRe = decCenterRe - (viewWidth / 2)
    let decStartIm = decCenterIm - (viewHeight / 2)
    
    return (
        startRe: SIMD4<Float32>(decStartRe.description),
        startIm: SIMD4<Float32>(decStartIm.description),
        delta: SIMD4<Float32>(decDelta.description)
    )
}

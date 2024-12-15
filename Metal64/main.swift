//
//  main.swift
//
//  Demo for MetalCompute class and metal64.h
//
//  Created by Dirk Braner on 15.12.24
//
//  Adapted from https://github.com/seprov/metal-vector-add/tree/main
//

import Foundation
import Metal

// Set number of elements to add
var count: Int = 10

do {
    let metalCompute = try MetalCompute("add_arrays")
    
    // Input Array 1
    let a1: [Float2] = Array(repeating: Float2(Double.pi), count: count)
    
    // Input Array 2
    let a2: [Float2] = Array(repeating: Float2(Double.pi), count: count)

    // Scalar value
    let x: Float2 = 10.0
    
    try metalCompute.addBuffer(a1)
    try metalCompute.addBuffer(a2)
    metalCompute.addValue(x)

    // Compute and show first 3 results
    if let result = metalCompute.compute(Float2()) {
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
print("pi = ", Double.pi)
print("pi + pi = \(Double.pi + Double.pi)")
print("pi * pi = \(Double.pi * Double.pi)")


// Add the arrays
// addTwoArraysOnGPU(arr1 : a1, arr2 : a2, printExtraInfo: true)

/*
func addTwoArraysOnGPU(arr1 : [Float2], arr2 : [Float2], printExtraInfo : Bool) {
    let commandQueue = device?.makeCommandQueue()
    let GPUFunctionLibrary = device?.makeDefaultLibrary()
    let additionGPUFunction = GPUFunctionLibrary?.makeFunction(name: "add_arrays")
    
    var additionComputePipelineState: MTLComputePipelineState!
    do {
        additionComputePipelineState = try device?.makeComputePipelineState(function: additionGPUFunction!)
    } catch {
        print(error)
    }
    
    // Create buffers
    let arr1Buf = device?.makeBuffer(bytes: arr1, length: MemoryLayout<Float2>.size * count, options: .storageModeShared)
    let arr2Buf = device?.makeBuffer(bytes: arr2, length: MemoryLayout<Float2>.size * count, options: .storageModeShared)
    let resultBuf = device?.makeBuffer(length: MemoryLayout<Float2>.size * count, options: .storageModeShared)
    
    let commandBuf = commandQueue?.makeCommandBuffer()
    
    let commandEncoder = commandBuf?.makeComputeCommandEncoder()
    commandEncoder?.setComputePipelineState(additionComputePipelineState)
    
    commandEncoder?.setBuffer(arr1Buf, offset: 0, index: 0)
    commandEncoder?.setBuffer(arr2Buf, offset: 0, index: 1)
    commandEncoder?.setBuffer(resultBuf, offset: 0, index: 2)
    
    let threadsPerGrid = MTLSize(width: count, height: 1, depth: 1)
    let maxThreadsPerGroup = additionComputePipelineState.maxTotalThreadsPerThreadgroup // this is intersting
    let threadsPerThreadGroup = MTLSize(width: maxThreadsPerGroup, height: 1, depth: 1)
    
    commandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
    
    commandEncoder?.endEncoding()
    
    commandBuf?.commit()
    commandBuf?.waitUntilCompleted()
    
    let resultBufferPointer = resultBuf?.contents().bindMemory(to: Float2.self, capacity: MemoryLayout<Float2>.size * count)
    
    if printExtraInfo {
        print("first 3 computations")
        for i in 0..<3 {
            let r = resultBufferPointer![i]
            print("\(Double(arr1[i])) \(arr1[i]) \(Double(r))", r)
            // print("\(Double(arr1[i])) \(Double(resultBufferPointer!.pointee) as Any)")
            // resultBufferPointer = resultBufferPointer?.advanced(by: 1)
        }
        print(arr1.count)
        print(arr2.count)
    }
}
*/



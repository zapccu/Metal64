//
//  MetalCompute.swift
//
//  Part of Metal64
//
//  Implementation of class MetalCompute
//
//  Created by Dirk Braner on 15.12.24.
//

import Metal


///
/// Class for Initializing and running Metal compute shaders from Swift
///
/// Usage:
///
/// 1. Create a MetalCompute object
/// 2. Add input parameters (arrays or scalar values)
/// 3. Call compute() method => returns array with results
///
class MetalCompute {

    // Error codes
    enum MetalError: Error {
        case deviceError(String)
        case libraryError(String)
        case commandQueueError(String)
        case commandBufferError(String)
        case computeEncoderError(String)
        case kernelFunctionError(String)
        case pipelineStateError(String)
        case addBufferError(String)
    }
    
    // Buffer types (arrays)
    enum BufferType: Int {
        case inputBuffer = 1
        case resultBuffer = 2
    }
    
    let fncName: String         // Kernel function name
    var bufferIndex: Int = 0    // I/O buffer index
    var count: Int = 0          // Number of elements in buffer
    
    var inputBuffers: [MTLBuffer] = []
    var resultBuffer: MTLBuffer?
    
    let device: MTLDevice
    let library: MTLLibrary
    let commandQueue: MTLCommandQueue
    let commandBuffer: MTLCommandBuffer
    let computeEncoder: MTLComputeCommandEncoder
    let kernelFunction: MTLFunction
    let pipelineState: MTLComputePipelineState
    
    ///
    /// Initialize metal device, create compute shaders
    ///
    /// Parameters:
    ///
    /// fncName - Name of kernel compute function
    ///
    init(_ fncName: String) throws {
        guard let device = MTLCreateSystemDefaultDevice() else { throw MetalError.deviceError("Cannot create device") }
        self.device = device
        guard let library = device.makeDefaultLibrary() else { throw MetalError.libraryError("Cannot create library") }
        self.library = library
        guard let commandQueue = device.makeCommandQueue() else { throw MetalError.commandQueueError("Cannnot create command queue") }
        self.commandQueue = commandQueue
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { throw MetalError.commandQueueError("Cannot create command buffer") }
        self.commandBuffer = commandBuffer
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { throw MetalError.commandBufferError("Cannot create compute encoder") }
        self.computeEncoder = computeEncoder
        guard let kernelFunction = library.makeFunction(name: fncName) else { throw MetalError.kernelFunctionError("Cannot make kernel function") }
        self.kernelFunction = kernelFunction
        do {
            let pipelineState = try device.makeComputePipelineState(function: kernelFunction)
            self.pipelineState = pipelineState
        }
        catch {
            throw MetalError.pipelineStateError("Cannot make pipeline state")
        }
        
        self.fncName = fncName
    }
    
    ///
    /// Create a buffer as a copy of specified array and add buffer to compute encoder
    ///
    /// Parameters:
    ///
    /// values - Array with initial buffer values
    /// bufferType - Type of buffer: .inputBuffer or .resultBuffer
    ///
    /// Return values:
    ///
    /// Either true or false
    ///
    func addBuffer<T>(_ value: [T], _ bufferType: BufferType = .inputBuffer) throws {
        if bufferIndex == 0 {
            count = value.count
        }
        else if count != value.count {
            throw MetalError.addBufferError("Element count mismatch")
        }
        
        let bufferSize = MemoryLayout<T>.size * count

        if let buffer = device.makeBuffer(bytes: value, length: bufferSize, options: .storageModeShared) {
            computeEncoder.setBuffer(buffer, offset: 0, index: bufferIndex)
            bufferIndex += 1
            if bufferType == .inputBuffer {
                inputBuffers.append(buffer)
            }
            else {
                resultBuffer = buffer
            }
        }
        else {
            throw MetalError.addBufferError("Cannot create buffer")
        }
    }
    
    ///
    /// Create a buffer with specified number of elements and add buffer to compute encoder
    ///
    /// Parameters:
    ///
    /// count - Number of elements in Buffer
    /// initValue - Initial value of type T for buffer
    /// bufferType - Type of buffer: .inputBuffer or .resultBuffer
    ///
    /// Return values:
    ///
    /// Either true or false
    ///
    func addBuffer<T>(_ count: Int, _ initValue: T, _ bufferType: BufferType = .inputBuffer) throws {
        try addBuffer(Array(repeating: initValue, count: count), bufferType)
    }
    
    ///
    /// Add a value to compute encoder
    ///
    /// Parameters:
    ///
    /// value - A numeric value of type Int, Float, Float2 or Double
    ///
    /// Either true or false
    ///
    func addValue(_ value: Int64) {
        var v = value
        computeEncoder.setBytes(&v, length: MemoryLayout<Int64>.size, index: bufferIndex)
        bufferIndex += 1
    }

    func addValue(_ value: Int32) {
        var v = value
        computeEncoder.setBytes(&v, length: MemoryLayout<Int32>.size, index: bufferIndex)
        bufferIndex += 1
    }
    
    func addValue(_ value: Float) {
        var v = value
        computeEncoder.setBytes(&v, length: MemoryLayout<Float>.size, index: bufferIndex)
        bufferIndex += 1
    }

    func addValue(_ value: Float2) {
        var v = value
        computeEncoder.setBytes(&v, length: MemoryLayout<Float2>.size, index: bufferIndex)
        bufferIndex += 1
    }

    func addValue(_ value: Double) {
        var v = Float2(value)
        computeEncoder.setBytes(&v, length: MemoryLayout<Float2>.size, index: bufferIndex)
        bufferIndex += 1
    }
    
    ///
    /// Call kernel function
    ///
    /// Parameters:
    ///
    /// initValue - Initial value of type T for result buffer
    ///
    /// Return values:
    ///
    /// Unsafe buffer pointer of type T pointing to results or nil on error
    ///
    func compute<T>(_ initValue: T) -> UnsafeBufferPointer<T>? {
        do {
            try addBuffer(count, initValue, .resultBuffer)
            
            // Calculate number of worker threads
            let gridSize = MTLSizeMake(count, 1, 1)
            let threadCount = min(pipelineState.maxTotalThreadsPerThreadgroup, count)
            let threadGroupSize = MTLSizeMake(threadCount, 1, 1)
            
            // Start computing and wait for results
            computeEncoder.setComputePipelineState(pipelineState)
            computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
            computeEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
            // Convert result buffer
            let converted = resultBuffer!.contents().bindMemory(to: T.self, capacity: count)
            return UnsafeBufferPointer(start: converted, count: count)
        } catch {
            return nil
        }
    }
}

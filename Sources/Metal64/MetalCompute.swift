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

public protocol MetalData {
    
}

///
/// Class for Initializing and running Metal compute shaders from Swift
///
/// Usage:
///
/// 1. Create a MetalCompute object
/// 2. Add input parameters (arrays or scalar values)
/// 3. Call compute() method => returns array with results
///
public class MetalCompute {

    // Error codes
    public enum MetalError: Error {
        case deviceError(String)
        case libraryError(String)
        case commandQueueError(String)
        case commandBufferError(String)
        case computeEncoderError(String)
        case kernelFunctionError(String)
        case pipelineStateError(String)
        case addBufferError(String)
        case computeElementsError(String)
    }
    
    // Buffer types (arrays)
    public enum BufferType: Int {
        case inputBuffer = 1
        case resultBuffer = 2
    }
    
    let fncName: String         // Kernel function name
    var bufferIndex: Int = 0    // I/O buffer index
    var count: Int = 0          // Number of elements in compute argument buffer(s)
    
    var resultBuffer: MTLBuffer?
    
    let device: MTLDevice
    let library: MTLLibrary
    var commandQueue: MTLCommandQueue?
    var commandBuffer: MTLCommandBuffer?
    var computeEncoder: MTLComputeCommandEncoder?
    let kernelFunction: MTLFunction
    let pipelineState: MTLComputePipelineState
    
    ///
    /// Initialize metal device, create compute shaders
    ///
    /// Parameters:
    ///
    /// fncName - Name of kernel compute function
    ///
    public init(_ fncName: String, _ count: Int) throws {
        guard count > 0 else { throw MetalError.computeElementsError("Number of elements must be greater than zero") }
        
        guard let device = MTLCreateSystemDefaultDevice() else { throw MetalError.deviceError("Cannot create device") }
        self.device = device
        
        guard let library = device.makeDefaultLibrary() else { throw MetalError.libraryError("Cannot create library") }
        self.library = library
        
        self.commandQueue = nil
        self.commandBuffer = nil
        self.computeEncoder = nil
        
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
        self.count = count
    }
    
    /// Prepare command queue, command buffer and compute encoder
    public func prepareComputeEncoder() throws {
        guard let commandQueue = device.makeCommandQueue() else {
            throw MetalError.commandQueueError("Cannnot create command queue")
        }
        self.commandQueue = commandQueue
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw MetalError.commandQueueError("Cannot create command buffer")
        }
        self.commandBuffer = commandBuffer
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw MetalError.commandBufferError("Cannot create compute encoder")
        }
        self.computeEncoder = computeEncoder
    }
    
    /// Add UnsafeMutableBuffer to encoder
    /// - Parameters:
    ///   - buffer: The buffer
    ///   - bufferType: Type of buffer. Default = .inputBuffer
    public func addBuffer<T>(_ buffer: UnsafeMutableBufferPointer<T>, _ bufferType: BufferType = .inputBuffer) throws {
        guard let computeEncoder else { throw MetalError.addBufferError("Cannot get compute encoder") }
        
        guard count == buffer.count else { throw MetalError.addBufferError("Element count mismatch") }
        let bufferSize = MemoryLayout<T>.stride * count

        guard let baseAddress = buffer.baseAddress else { throw MetalError.addBufferError("Cannot get buffer base address") }
        
        if let metalBuffer = device.makeBuffer(bytes: baseAddress, length: bufferSize, options: .storageModeShared) {
            computeEncoder.setBuffer(metalBuffer, offset: 0, index: bufferIndex)
            bufferIndex += 1
            if bufferType == .resultBuffer {
                resultBuffer = metalBuffer
            }
        }
        else {
            throw MetalError.addBufferError("Cannot create buffer")
        }
    }

    /// Add array to compute encoder
    /// - Parameters:
    ///   - value: The array
    ///   - bufferType: Type of buffer. Default = .inputBuffer
    public func addArray<T>(_ value: [T], _ bufferType: BufferType = .inputBuffer) throws {
        guard let computeEncoder else { throw MetalError.addBufferError("Cannot get compute encoder") }

        guard count == value.count else { throw MetalError.addBufferError("Element count mismatch") }
        
        let bufferSize = MemoryLayout<T>.stride * count

        let buffer = try value.withUnsafeBufferPointer { (bufferPtr) -> MTLBuffer? in
            guard let baseAddress = bufferPtr.baseAddress else { throw MetalError.addBufferError("Cannot get buffer base address") }
            return device.makeBuffer(bytes: baseAddress, length: bufferSize, options: .storageModeShared)
        }

        if let buffer = buffer {
            computeEncoder.setBuffer(buffer, offset: 0, index: bufferIndex)
            bufferIndex += 1
            if bufferType == .resultBuffer {
                resultBuffer = buffer
            }
        }
        else {
            throw MetalError.addBufferError("Cannot create buffer")
        }
    }
    
    /// Create array with specified number of elements and add it to compute encoder
    /// - Parameters:
    ///   - count: Number of array elements
    ///   - initValue: Initial value for array elements
    ///   - bufferType: Type of buffer. Default = .inputBuffer
    public func addArray<T>(_ count: Int, _ initValue: T, _ bufferType: BufferType = .inputBuffer) throws {
        try addArray(Array(repeating: initValue, count: count), bufferType)
    }
    
    /// Add a struct conform to MetalData to compute encoder
    /// - Parameter value: The structure
    public func addStruct<T: MetalData>(_ value: T) throws {
        var v = value
        
        guard let computeEncoder else { throw MetalError.addBufferError("Cannot get compute encoder") }

        withUnsafePointer(to: &v) { ptr in
            computeEncoder.setBytes(ptr, length: MemoryLayout<T>.stride, index: bufferIndex)
        }

        bufferIndex += 1
    }
    
    /// Add a value to compute encoder
    /// - Parameter value: The value
    public func addValue<T>(_ value: T) throws {
        var v = value
        
        guard let computeEncoder else { throw MetalError.computeEncoderError("Cannot get compute encoder") }

        computeEncoder.setBytes(&v, length: MemoryLayout<T>.size, index: bufferIndex)
        bufferIndex += 1
    }
    
    /// Add array to compute decoder
    /// - Parameter value: Array of values
    public func addValue<T>(_ value: [T]) throws {
        guard let computeEncoder else { throw MetalError.computeEncoderError("Cannot get compute encoder") }

        let bufferSize = MemoryLayout<T>.stride * count

        let buffer = try value.withUnsafeBufferPointer { (bufferPtr) -> MTLBuffer? in
            guard let baseAddress = bufferPtr.baseAddress else { throw MetalError.addBufferError("Cannot get buffer base address") }
            return device.makeBuffer(bytes: baseAddress, length: bufferSize, options: .storageModeShared)
        }

        if let buffer = buffer {
            computeEncoder.setBuffer(buffer, offset: 0, index: bufferIndex)
            bufferIndex += 1
        }
        else {
            throw MetalError.addBufferError("Cannot create buffer")
        }
    }
    
    /// Call kernel function
    /// - Parameter initValue: Initial value for result array
    /// - Returns: Result array or nil on error
    public func compute<T>(_ initValue: T) -> [T]? {
        do {
            guard let computeEncoder else { throw MetalError.computeEncoderError("Cannot get compute encoder") }
            guard let commandBuffer else { throw MetalError.commandBufferError("Cannot get command buffer") }
            
            try addArray(count, initValue, .resultBuffer)
            
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
            
            self.computeEncoder = nil
            self.commandBuffer = nil
            self.commandQueue = nil
            
            // Convert result buffer into array
            let converted = resultBuffer!.contents().bindMemory(to: T.self, capacity: count)
            return Array(UnsafeBufferPointer(start: converted, count: count))
        } catch {
            return nil
        }
    }
}

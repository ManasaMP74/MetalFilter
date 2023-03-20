//
//  BufferProvider.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import Foundation
import Metal

//BufferProvider will be responsible for creating a pool of buffers, and it will have a method to get the next available reusable buffer. This is kind of like UITableViewCell!

// increase performance using threads.

/*
 how you’ll use a semaphore in this example:

 - Initialize with the number of buffers. You’ll be using the semaphore to keep track of how many buffers are currently in use on the GPU, so you’ll initialize the semaphore with the number of buffers that are available (3 to start in this case).
 
 - Wait before accessing a buffer. Every time you need to access a buffer, you’ll ask the semaphore to “wait”. If a buffer is available, you’ll continue running as usual (but decrement the count on the semaphore). If all buffers are in use, this will block the thread until one becomes available. This should be a very short wait in practice as the GPU is fast.
 
 - Signal when done with a buffer. When the GPU is done with a buffer, you will “signal” the semaphore to track that it’s available again.
 */

class BufferProvider {
    let inflightBuffersCount: Int // that will store the number of buffers stored by BufferProvider
    private var uniformsBuffers: [MTLBuffer] // An array that will store the buffers themselves.

    private var avaliableBufferIndex: Int = 0
    
    var avaliableResourcesSemaphore: DispatchSemaphore
    
    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        
      self.inflightBuffersCount = inflightBuffersCount
      avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)

      uniformsBuffers = [MTLBuffer]()
        
      for _ in 0...inflightBuffersCount-1 {
        let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
          uniformsBuffers.append(uniformsBuffer as! MTLBuffer)
      }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer {
      let buffer = uniformsBuffers[avaliableBufferIndex]
      let bufferPointer = buffer.contents()

      memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
      memcpy(bufferPointer + MemoryLayout<Float>.size*Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
        
      avaliableBufferIndex += 1
      if avaliableBufferIndex == inflightBuffersCount{
        avaliableBufferIndex = 0
      }
        
      return buffer
    }

    //deinit simply does a little cleanup before object deletion. Without this, your app would crash when the semaphore is waiting and you’d deleted BufferProvider.
    deinit{
      for _ in 0...self.inflightBuffersCount{
        self.avaliableResourcesSemaphore.signal()
      }
    }
}

// for lighting
extension BufferProvider {
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4, light: Light) -> MTLBuffer {
        let buffer = uniformsBuffers[avaliableBufferIndex]
        let bufferPointer = buffer.contents()

        memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size*Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
        memcpy(bufferPointer + 2*MemoryLayout<Float>.size*Matrix4.numberOfElements(), light.raw(), Light.size())
        
        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount{
          avaliableBufferIndex = 0
        }
          
        return buffer
    }
}

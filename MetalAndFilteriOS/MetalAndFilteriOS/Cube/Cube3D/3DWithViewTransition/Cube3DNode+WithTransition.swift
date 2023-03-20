//
//  Cube3DNode+WithTransition.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

import Foundation
//with view transition and to provide transparency in 3d design
extension Cube3DNode {
   
    func render(commandQueue: MTLCommandQueue,
                pipelineState: MTLRenderPipelineState,
                drawable: CAMetalDrawable,
                parentModelViewMatrix: Matrix4,
                projectionMatrix: Matrix4,
                clearColor: MTLClearColor?) {
        let renderDiscription = MTLRenderPassDescriptor()
        renderDiscription.colorAttachments[0].texture = drawable.texture
        renderDiscription.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderDiscription.colorAttachments[0].loadAction = .clear
        renderDiscription.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDiscription)!
        
        //For now cull mode is used instead of depth buffer to keep transparency of cube
        renderEncoder.setCullMode(MTLCullMode.front)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        // if you passing 2 matrix for 3d design we need 2 buffer
        // for 1 matrix buffer created as
        //let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements(), options: [])!
        
        /*
         this is a performance issue bcz it allocates a buffer each time.
         instead of allocating a buffer each time, you’ll reuse a pool of buffers.
         */
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements()*2, options: [])!
        
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// fix performanceIssue

extension Cube3DNode {
    
     func renderWithPerform(commandQueue: MTLCommandQueue,
                 pipelineState: MTLRenderPipelineState,
                 drawable: CAMetalDrawable,
                 parentModelViewMatrix: Matrix4,
                 projectionMatrix: Matrix4,
                 clearColor: MTLClearColor?) {
         //This will make the CPU wait in case bufferProvider.avaliableResourcesSemaphore has no free resources.
         _ = bufferProvider.avaliableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
         
         let renderDiscription = MTLRenderPassDescriptor()
         renderDiscription.colorAttachments[0].texture = drawable.texture
         renderDiscription.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
         renderDiscription.colorAttachments[0].loadAction = .clear
         renderDiscription.colorAttachments[0].storeAction = .store
         
         let commandBuffer = commandQueue.makeCommandBuffer()!
         //you need to signal the semaphore when the resource becomes available.
         
         //When the GPU finishes rendering, it executes a completion handler to signal the semaphore and bumps its count back up again.
         commandBuffer.addCompletedHandler { (_) in
           self.bufferProvider.avaliableResourcesSemaphore.signal()
         }
         
         let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDiscription)!
         
         //For now cull mode is used instead of depth buffer to keep transparency of cube
         renderEncoder.setCullMode(MTLCullMode.front)
         
         renderEncoder.setRenderPipelineState(pipelineState)
         renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
         
         let nodeModelMatrix = self.modelMatrix()
         nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
         let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix)
         renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
         renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
         renderEncoder.endEncoding()
         
         commandBuffer.present(drawable)
         commandBuffer.commit()
     }
}

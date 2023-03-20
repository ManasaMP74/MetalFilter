//
//  Cube3DNode+WithoutTransition.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

import Foundation
//without viewtransition

extension Cube3DNode {
    
    func render(commandQueue: MTLCommandQueue,
                pipelineState: MTLRenderPipelineState,
                drawable: CAMetalDrawable,
                projectionMatrix: Matrix4,
                clearColor: MTLClearColor?) {
        let renderDiscription = MTLRenderPassDescriptor()
        renderDiscription.colorAttachments[0].texture = drawable.texture
        renderDiscription.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderDiscription.colorAttachments[0].loadAction = .clear
        renderDiscription.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDiscription)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        let nodeModelMatrix = self.modelMatrix()
        
        // if you passing 2 matrix for 3d design we need 2 buffer
        // for 1 matrix buffer created as
        //let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements(), options: [])!
        
        /*
         this is a performance issue bcz it allocates a buffer each time.
         instead of allocating a buffer each time, you’ll reuse a pool of buffers.
         */
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements()*2, options: [])!
        
        let bufferPointer = uniformBuffer.contents()
        
        //You added a model transformation, which allows you to modify an object’s location, size and rotation.
        //You added a projection transformation, which allows you to shift from an orthographic to a more natural perspective projection.
        
        /*
         There are actually two more transformations beyond this that are typically used in a 3D rendering pipeline:

         View transformation: What if you want to look at the scene from a different position? You could move every object in the scene by modifying all of their model transformations, but this is inefficient. It’s often convenient to have a separate transformation that represents how you’re looking at the scene, which is your “camera”.
         Viewport transformation: This takes the little world you’ve created in normalized coordinates and maps it to the device screen. This is handled automatically by Metal, so you don’t need to do anything; it’s just something worth knowing.

         */
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}




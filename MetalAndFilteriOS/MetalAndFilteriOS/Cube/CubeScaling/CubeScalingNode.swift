//
//  Cube3DNode.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import Foundation
import simd

class CubeScalingNode {
    var modelTransformationMatrix = float4x4()
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    var device: MTLDevice!
    var name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        let dataSize = vertexData.count*MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        self.name = name
        self.device = device
        self.vertexCount = vertices.count
    }
    
    func render(commandQueue: MTLCommandQueue,
                pipelineState: MTLRenderPipelineState,
                drawable: CAMetalDrawable,
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
        
        //this line is for cube rotation
        /*
         Call the method you wrote earlier to convert the convenience properties (like position and rotation) into a model matrix.
         
         Ask the device to create a buffer with shared CPU/GPU memory.
         
         Get a raw pointer from buffer (similar to void * in Objective-C).
         
         Copy your matrix data into the buffer.
         
         Pass uniformBuffer (with data copied) to the vertex shader. This is similar to how you sent the buffer of vertex-specific data, except you use index 1 instead of 0.
         */
        let nodeModelMatrix = self.modelMatrix()
        // if you passing 2 matrix for 3d design we need 2 buffer
        // for 1 matrix buffer created as
        //let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements(), options: [])!
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements(), options: [])!
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
}

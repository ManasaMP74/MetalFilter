//
//  Node.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import Foundation
import Metal
import QuartzCore

class Node {
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
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, clearColor: MTLClearColor?) {
        let renderDiscription = MTLRenderPassDescriptor()
        renderDiscription.colorAttachments[0].texture = drawable.texture
        renderDiscription.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderDiscription.colorAttachments[0].loadAction = .clear
        renderDiscription.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDiscription)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

//
//  Cube3DNode.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import Foundation
import simd

class Cube3DNode {
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
    
    //rotate cube with time
    var time:CFTimeInterval = 0.0
    
    
    //to use BufferProvider
    var bufferProvider: BufferProvider
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
    
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
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
    }
    
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
}



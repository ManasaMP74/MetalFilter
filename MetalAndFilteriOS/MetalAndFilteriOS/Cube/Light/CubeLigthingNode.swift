//
//  CubeLigthing.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

class CubeLigthingNode {
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
    
    //to use BufferProvider
    var bufferProvider: BufferProvider
    
    // ligthing
    
    /*
     for diffuse light
     let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8)

     */
    
    /*
     for specular light
     let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.1, direction: (0.0, 0.0, 1.0), diffuseIntensity: 0.8, shininess: 10, specularIntensity: 2)

     */
    let light = Light(color: (1.0,1.0,1.0), ambientIntensity: 0.2)

    init(name: String, vertices: Array<CubeVertex>, device: MTLDevice) {
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        let dataSize = vertexData.count*MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        self.name = name
        self.device = device
        self.vertexCount = vertices.count
        
        let sizeOfUniformsBuffer = MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2 + Light.size()
        
        self.bufferProvider = BufferProvider(device: device, inflightBuffersCount: 3, sizeOfUniformsBuffer: sizeOfUniformsBuffer)
    }
}

extension CubeLigthingNode {
   
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
        
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements()*2, options: [])!
        
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)

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

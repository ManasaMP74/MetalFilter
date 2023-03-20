//
//  MetalRender.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import MetalKit
class MetalRender: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var timer: Float = 0
    
    init(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        MetalRender.device = device
        metalView.device = device
        MetalRender.commandQueue = device.makeCommandQueue()
        
        let mdlMesh = Primitive.makeCube(device: device, size: 1)
        do {
          mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
          print(error.localizedDescription)
        }
        
        //set up the MTLBuffer that contains the vertex data you’ll send to the GPU.
        vertexBuffer = mesh.vertexBuffers[0].buffer

        
        //you need to set up the pipeline state so that the GPU will know how to render the data.
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //You set the two shader functions the GPU will call, and you also set the pixel format for the texture to which the GPU will write.
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        do {
          pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
          fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
    
    func initialize() {
        
    }
}

extension MetalRender: MTKViewDelegate {
    //Gets called every time the size of the window changes. This allows you to update the render coordinate system.
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
  }
  
    //Gets called every frame.
  func draw(in view: MTKView) {
      guard let descriptor = view.currentRenderPassDescriptor,
        let commandBuffer = MetalRender.commandQueue.makeCommandBuffer(),
        let renderEncoder =
          commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
          return
      }

      // 1
      timer += 0.05
      var currentTime = sin(timer)
      // 2
      //if you’re only sending a small amount of data (less than 4kb) to the GPU, setVertexBytes(_:length:index:) is an alternative to setting up a MTLBuffer.
      renderEncoder.setVertexBytes(&currentTime,
                                    length: MemoryLayout<Float>.stride,
                                    index: 1)
      
      renderEncoder.setRenderPipelineState(pipelineState)
      renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
      for submesh in mesh.submeshes {
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                           indexCount: submesh.indexCount,
                           indexType: submesh.indexType,
                           indexBuffer: submesh.indexBuffer.buffer,
                           indexBufferOffset: submesh.indexBuffer.offset)
      }

      renderEncoder.endEncoding()
      guard let drawable = view.currentDrawable else {
        return
      }
      commandBuffer.present(drawable)
      commandBuffer.commit()

  }
}

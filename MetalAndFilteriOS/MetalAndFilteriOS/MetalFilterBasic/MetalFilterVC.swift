//
//  MetalFilterVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 08/03/23.
//

import UIKit
import Metal

class MetalFilterVC: UIViewController {
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    let vertexData: [Float] = [ 0, 1, 0,
                       -1,-1,0,
                       1,-1,0
    ]
    var vertextBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        setupMetalLayer()
        setupBuffer()
        renderPipeline()
        createCommandQueue()
    }
    
    func setupMetalLayer() {
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
    }
    
    func setupBuffer() {
        let dataSize = vertexData.count*MemoryLayout.size(ofValue: vertexData[0])
        vertextBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    }
    
    func renderPipeline() {
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basicFragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basicVertex")
        let pipelineDiscriptor = MTLRenderPipelineDescriptor()
        pipelineDiscriptor.vertexFunction = vertexProgram
        pipelineDiscriptor.fragmentFunction = fragmentProgram
        pipelineDiscriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDiscriptor)
    }
    
    func createCommandQueue() {
        commandQueue = device.makeCommandQueue()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
        
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDiscriptor = MTLRenderPassDescriptor()
        renderPassDiscriptor.colorAttachments[0].texture = drawable.texture
        renderPassDiscriptor.colorAttachments[0].loadAction = .clear
        renderPassDiscriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 104/255, blue: 55/255, alpha: 1)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDiscriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertextBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

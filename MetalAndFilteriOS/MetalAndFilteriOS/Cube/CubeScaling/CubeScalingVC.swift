//
//  CubeVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import UIKit
import MetalKit

class CubeScalingVC: UIViewController {
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var objectToDraw: CubeScaling!
    var pipelineState: MTLRenderPipelineState!
    var timer: CADisplayLink!

    override func viewDidLoad() {
        super.viewDidLoad()
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.frame
        view.layer.addSublayer(metalLayer)
        objectToDraw = CubeScaling(device: device)
        
        objectToDraw.positionY =  0.25
        objectToDraw.positionZ = -0.25
        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45)
        objectToDraw.scale = 0.5
        
        setupCommandQueue()
    }
    
    func setupCommandQueue() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "cubeVertexWithMatrix4ForScaling")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "cubeFragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        commandQueue = device.makeCommandQueue()
        timer = CADisplayLink(target: self, selector: #selector(gameon))
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    @objc func gameon() {
        autoreleasepool {
            self.render()
        }
    }

    func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    

}


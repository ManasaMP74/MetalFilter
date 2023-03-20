//
//  CubeVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import UIKit
import MetalKit

class CubeLightVC: UIViewController {
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var objectToDraw: CubeLight!
    var pipelineState: MTLRenderPipelineState!
    var timer: CADisplayLink!
    var projectionMatrix: Matrix4!

    override func viewDidLoad() {
        super.viewDidLoad()
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.frame
        view.layer.addSublayer(metalLayer)
        objectToDraw = CubeLight(device: device)
        
        objectToDraw.positionX = 0.0
        objectToDraw.positionY =  0.0
        objectToDraw.positionZ = -2.0
        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45);
        objectToDraw.scale = 0.5
        
        setupCommandQueue()
    }
    
    func setupCommandQueue() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "basic_vertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "basic_fragment")
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
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
}


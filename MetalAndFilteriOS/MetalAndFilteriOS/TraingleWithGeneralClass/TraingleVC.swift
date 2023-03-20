//
//  TraingleVC.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import UIKit
import simd

class TraingleVC: UIViewController {
    var objectToDraw: Triangle!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var timer: CADisplayLink!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!

    override func viewDidLoad() {
        super.viewDidLoad()
        device = MTLCreateSystemDefaultDevice()
        setupMetalLayer()
        objectToDraw = Triangle(device: device)
        createPipeLineState()
        createCommandQueue()
    }
    
    func setupMetalLayer() {
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.frame
        view.layer.addSublayer(metalLayer)
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func createPipeLineState() {
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basicTraingleFragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basicTraingleVertex")
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
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
}

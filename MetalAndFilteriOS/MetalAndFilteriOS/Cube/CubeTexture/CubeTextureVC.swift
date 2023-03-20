//
//  CubeTexture.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import Foundation

class CubeTextureVC: UIViewController {
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var objectToDraw: CubeTexture!
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
        /*
         for device with orientation
         remove metalLayer.frame = view.frame and add below code
         if let window = view.window {
             let scale = window.screen.nativeScale
             let layerSize = view.bounds.size
             //2
             view.contentScaleFactor = scale
             metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
             metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
           }
         */
        view.layer.addSublayer(metalLayer)
        setupCommandQueue()
        objectToDraw = CubeTexture(device: device, commandQ: commandQueue)
    }
    
    func setupCommandQueue() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = device.makeDefaultLibrary()!
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "basic_textureVertex")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "basic_texturefragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
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
        guard let drawable = metalLayer.nextDrawable() else { return }
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)

        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
}


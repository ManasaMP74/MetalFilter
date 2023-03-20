//
//  ViewController.swift
//  MetalAndFilters
//
//  Created by rishav kohli on 19/01/22.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    @IBOutlet weak var originalImageView: UIView!
    var metalView: MTKView = MTKView()
    @IBOutlet weak var filterImageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var originalImageHeight: NSLayoutConstraint!
    var image: UIImage? =  nil
    @IBOutlet weak var intensitySlider: UISlider!
    
    var metalDevice: MTLDevice? = nil
    
    var metalCommandQueue: MTLCommandQueue? = nil
    
    var ciContext: CIContext? = nil
   
    var ciImage : CIImage? = nil
    
    var filteredCiImage: CIImage? = nil
    var scaledImage: CIImage? = nil
    var alpha = CGFloat(1)
    
    let customFilter: ThreeDyeFilter = ThreeDyeFilter()
    
    let fadeFilter = CIFilter(name: "CIPhotoEffectFade")
    let sepiaFilter = CIFilter(name: "CISepiaTone")
    
    var rect: CGRect? = nil
    
    var vertices1: [VertexInfo] = [
        VertexInfo(position: float3(-1,1,0), color: float4(1,0,0,1), texture: float2(0,0)),
        VertexInfo(position: float3(-1,-1,0), color: float4(0,1,0,1), texture: float2(0,1)),
        VertexInfo(position: float3(1,-1,0), color: float4(0,0,1,1), texture: float2(1,1)),
        VertexInfo(position: float3(1,1,0), color: float4(0.94,1,0,1), texture: float2(1,0))
    ]
    
    var indices: [UInt16] = [
    0,1,2,
    2,3,0
    ]
    
    var pipelineState: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var texture: MTLTexture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = UIImage(named: "Unknown"){
            self.image = image
            ciImage = CIImage(image: image)
        }
        
        setupSlider()
        setupView()
        setupMetal()
        
        if let device = metalDevice {
            ciContext = CIContext(mtlDevice: device)
            if let image = UIImage(named: "sample"), let cgImage =  image.cgImage{
                self.texture = self.setTexture(device: device, image: cgImage)
            }
            
        }
       // self.ciImage = scaleImageForMetalView()
        
        self.scaledImage = scaleImageForMetalView()
        customFilter.inputImage = self.ciImage
       
        
    }
    
    private func buildVertexBuffer(){
        vertexBuffer = metalDevice?.makeBuffer(bytes: vertices1, length: vertices1.count * MemoryLayout<VertexInfo>.stride, options: [])
        indexBuffer = metalDevice?.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    private func buildPipelineState(){
        let library = metalDevice?.makeDefaultLibrary()
        let vertexShader = library?.makeFunction(name: "vertexShader")
        let fragmentShader = library?.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexShader
        pipelineDescriptor.fragmentFunction = fragmentShader

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride

        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride

        vertexDescriptor.layouts[0].stride = MemoryLayout<VertexInfo>.stride


        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
             pipelineState = try metalDevice?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error :" + "\(error.localizedDescription)")
        }
    }
    
    func setupSlider(){
        intensitySlider.minimumValue = 0.0
        intensitySlider.maximumValue = 1.0
        intensitySlider.isContinuous = true
        intensitySlider.setValue(1.0, animated: true)
    }
    
    @IBAction func intensityValueChanged(_ sender: Any) {
        self.alpha = CGFloat(intensitySlider.value)
    }
    
    func applyFilters(inputImage image: CIImage) -> CIImage? {
            var filteredImage : CIImage?
            
            //apply filters
            sepiaFilter?.setValue(image, forKeyPath: kCIInputImageKey)
            sepiaFilter?.setValue(alpha, forKey: kCIInputIntensityKey)
            filteredImage = sepiaFilter?.outputImage
        
                  
//            fadeFilter?.setValue(image, forKeyPath: kCIInputImageKey)
//            filteredImage = fadeFilter?.outputImage
            
            return filteredImage
        }

    
    func scaleImageForMetalView()-> CIImage?{
        guard let image = self.ciImage else {return nil}

        let dpi = UIScreen.main.nativeScale
        let width = filterImageView.bounds.width * dpi
        let height = filterImageView.bounds.height * dpi
        rect = CGRect(x: 0, y: 300, width: width, height: height)
      //  metalView.drawableSize = image.extent.size
        let extent = image.extent
        var xScale = extent.width > 0 ? width  / (extent.width)  : 1
        var yScale = extent.height > 0 ? height / (extent.height) : 1
        let scale = max(xScale, yScale)
        
        if xScale > yScale {
            yScale = xScale / yScale
            xScale = 1.0
        } else {
            xScale = yScale / xScale
            yScale = 1.0
        }
        
        
//        let tx = (width - extent.width * scale) / 2
//        let ty = (height - extent.height * scale) / 2
        let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale, tx: xScale, ty: yScale)
        let filter = CIFilter(name: "CIAffineTransform",
                                      parameters: ["inputImage": image, "inputTransform": transform])!
        return filter.outputImage
    }
    
    
    func setupView(){
        self.originalImageHeight.constant = ((UIScreen.main.bounds.height) / 2) - 20
        metalView = MTKView(frame: .init(x: 20, y: 20, width: self.filterImageView.frame.width, height: self.filterImageView.frame.height) )
        metalView.backgroundColor = .red
        metalView.translatesAutoresizingMaskIntoConstraints = false
        self.filterImageView.addSubview(metalView)
        
        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(equalTo: self.filterImageView.topAnchor),
            metalView.bottomAnchor.constraint(equalTo: self.filterImageView.bottomAnchor),
            metalView.leadingAnchor.constraint(equalTo: self.filterImageView.leadingAnchor ),
            metalView.trailingAnchor.constraint(equalTo: self.filterImageView.trailingAnchor)
        ])
        if let image = self.ciImage {
            self.imageView.image = UIImage(ciImage: image)
        }
        
    }
    func setupMetal(){
        //fetch the default gpu of the device (only one on iOS devices)
        metalDevice = MTLCreateSystemDefaultDevice()
        
        //tell our MTKView which gpu to use
        metalView.device = metalDevice
        
        //tell our MTKView to use explicit drawing meaning we have to call .draw() on it
//        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = false
        
        //create a command queue to be able to send down instructions to the GPU
        metalCommandQueue = metalDevice?.makeCommandQueue()
        
        //conform to our MTKView's delegate
        metalView.delegate = self
        
        //let it's drawable texture be writen to
        metalView.framebufferOnly = false
        
        buildVertexBuffer()
        
        buildPipelineState()
    }
    
    

}

extension ViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        return
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = metalCommandQueue?.makeCommandBuffer(), let currentDrawable = metalView.currentDrawable , let scaledImage = self.scaledImage,
              var filterCiImage = applyFilters(inputImage: scaledImage),
              let rect = self.rect,
              let texture = self.texture,
              let pipelineState = pipelineState,
              let indexBuffer = indexBuffer,
              let descriptor = view.currentRenderPassDescriptor
        else {return}
        customFilter.inputImage = self.ciImage
        customFilter.alpha = Float(self.alpha)
        
        guard var filterCiImage = customFilter.outputImage else {return}
        if let cgImage = ciContext?.createCGImage(filterCiImage, from: filterCiImage.extent), let device = self.metalDevice{
            self.texture = self.setTexture(device: device, image: cgImage)
        }
       
        
        
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setFragmentTexture(texture, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices1.count)
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
         commandEncoder?.endEncoding()
        
            //self.imageView.image = UIImage(ciImage: image)
            
            #if targetEnvironment(simulator)
         
           filterCiImage = filterCiImage.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
                .transformed(by: CGAffineTransform(translationX: 0, y: filterCiImage.extent.height))
            #endif
            
            self.ciContext?.render(filterCiImage, to: currentDrawable.texture, commandBuffer: commandBuffer, bounds: rect, colorSpace: CGColorSpaceCreateDeviceRGB())
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        
    }
    
    
}
extension ViewController: Texturable{
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {

        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height

        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        // Create a new UIImage object
        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }
}

extension UIImage {
   
    func makebillBoardMaskImage(width: CGFloat, height: CGFloat) -> UIImage {
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        //let imageRect = CGRect(origin: CGPoint.zero, size: self.size)
        let colorSpace = CGColorSpaceCreateDeviceGray()

        let width = width
        let height = height

        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue)

        // set Fill Color to White (or some other color)
        context?.setFillColor(UIColor.clear.cgColor)
       // context?.setFillColor(<#CGColor#>)
        // Draw a white-filled rectangle before drawing your image
        context?.fill(imageRect)
        
//        context?.setFillColor(UIColor.black.cgColor)
//        context?.fill(CGRect(x: 20, y: height - 20 - self.size.height, width: self.size.width, height: self.size.height))
        
        context?.draw(self.cgImage!, in: CGRect(x: 20, y: height - 20 - self.size.height, width: self.size.width, height: self.size.height))

        let imageRef = context?.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
      
   
    
    func mask(width: CGFloat, height: CGFloat) -> UIImage {
        let imageSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        draw(in: CGRect(x: 20, y: 20, width: self.size.width, height: self.size.height), blendMode: .normal, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    
}


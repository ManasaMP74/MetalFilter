

import CoreImage
import Vision

class ImageProcessor {
  var frameBuffer: [CIImage] = []
  var alignedFrameBuffer: [CIImage] = []
  var completion: ((CIImage) -> Void)?
  var isProcessingFrames = false
  var frameCount: Int {
    return frameBuffer.count
  }
  
  func add(_ frame: CIImage) {
    if isProcessingFrames {
      return
    }
    frameBuffer.append(frame)
  }
  
  func processFrames(completion: ((CIImage) -> Void)?) {
    isProcessingFrames = true
    self.completion = completion
    let firstFrame = frameBuffer.removeFirst()
    alignedFrameBuffer.append(firstFrame)
    for frame in frameBuffer {
      let request = VNTranslationalImageRegistrationRequest(targetedCIImage: frame)
      do {
        let sequenceHandler = VNSequenceRequestHandler()
        try sequenceHandler.perform([request], on: firstFrame)
      } catch {
        print(error.localizedDescription)
      }
      alignImages(request: request, frame: frame)
    }
    combineFrames()
  }
  
  func alignImages(request: VNRequest, frame: CIImage) {
    guard
      let results = request.results as? [VNImageTranslationAlignmentObservation],
      let result = results.first
      else {
        return
    }
    let alignedFrame = frame.transformed(by: result.alignmentTransform)
    alignedFrameBuffer.append(alignedFrame)
  }
  
  func combineFrames() {
    var finalImage = alignedFrameBuffer.removeFirst()
    let filter = AverageStackingFilter()
    for (i, image) in alignedFrameBuffer.enumerated() {
      filter.inputCurrentStack = finalImage
      filter.inputNewImage = image
      filter.inputStackCount = Double(i + 1)
      finalImage = filter.outputImage()!
    }
    cleanup(image: finalImage)
  }
  
  func cleanup(image: CIImage) {
    frameBuffer = []
    alignedFrameBuffer = []
    isProcessingFrames = false
    if let completion = completion {
      DispatchQueue.main.async {
        completion(image)
      }
    }
    completion = nil
  }
}

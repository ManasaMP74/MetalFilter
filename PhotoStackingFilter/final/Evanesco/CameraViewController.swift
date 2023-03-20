

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
  @IBOutlet var previewView: UIView!
  @IBOutlet var containerView: UIView!
  @IBOutlet var combinedImageView: UIImageView!
  @IBOutlet var recordButton: RecordButton!
  var previewLayer: AVCaptureVideoPreviewLayer!
  let session = AVCaptureSession()
  var saver: ImageSaver?
  let imageProcessor = ImageProcessor()
  var isRecording = false
  let maxFrameCount = 20
  
  override func viewDidLoad() {
    super.viewDidLoad()
    containerView.isHidden = true
    configureCaptureSession()
    session.startRunning()
  }
}

// MARK: - Configuration Methods

extension CameraViewController {
  func configureCaptureSession() {
    guard let camera = AVCaptureDevice.default(for: .video) else {
      fatalError("No video camera available")
    }
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      session.addInput(cameraInput)
      try camera.lockForConfiguration()
      camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 5)
      camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 5)
      camera.unlockForConfiguration()
    } catch {
      fatalError(error.localizedDescription)
    }
    // Define where the video output should go
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video data queue"))
    //videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    // Add the video output to the capture session
    session.addOutput(videoOutput)
    let videoConnection = videoOutput.connection(with: .video)
    videoConnection?.videoOrientation = .portrait
    // Configure the preview layer
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = view.bounds
    previewView.layer.addSublayer(previewLayer)
  }
}

// MARK: - UI Methods

extension CameraViewController {
  @IBAction func recordTapped(_ sender: UIButton) {
    recordButton.isEnabled = false
    isRecording = true
    saver = ImageSaver()
  }
  
  @IBAction func closeButtonTapped(_ sender: UIButton) {
    containerView.isHidden = true
    recordButton.isEnabled = true
    session.startRunning()
  }

  func stopRecording() {
    isRecording = false
    recordButton.progress = 0.0
  }
  
  func displayCombinedImage(_ image: CIImage) {
    session.stopRunning()
    combinedImageView.image = UIImage(ciImage: image)
    containerView.isHidden = false
  }
}

// MARK: - Capture Video Data Delegate Methods

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if !isRecording {
      return
    }
    guard
      let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
      let cgImage = CIImage(cvImageBuffer: imageBuffer).cgImage()
      else {
        return
    }
    let image = CIImage(cgImage: cgImage)
    imageProcessor.add(image)
    saver?.write(image)
    let currentFrame = recordButton.progress * CGFloat(maxFrameCount)
    recordButton.progress = (currentFrame + 1.0) / CGFloat(maxFrameCount)
    if recordButton.progress >= 1.0 {
      stopRecording()
      imageProcessor.processFrames(completion: displayCombinedImage)
    }
  }
}

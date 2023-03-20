// Recording Video. for photo alignment


// photostacking is filtering unneccessary object and focus only on one item.
//photo stacking is a technique where multiple images are captured, aligned and combined to create different desired effects.
/*
 https://www.kodeco.com/3733151-photo-stacking-in-ios-with-vision-and-metal#toc-anchor-001
 */

/*
 - frameBuffer will store the original captured images.
 
 - alignedFrameBuffer will contain the images after they have been aligned.
 completion is a handler that will be called after the images have been aligned and combined.
 
 - isProcessingFrames will indicate whether images are currently being aligned and combined.
 
 - frameCount is the number of images captured.
 */

/*
 vision framework is used for photostacking
 
 The Vision framework has two different APIs for aligning images:
 - VNTranslationalImageRegistrationRequest and
 - VNHomographicImageRegistrationRequest
 */

/*
 To compile and link your Metal file, you need to add two flags to your Build Settings. So head on over there.

 Search for Other Metal Compiler Flags and add -fcikernel to it:
 
 Metal compiler flag

 Next, click the + button and select Add User-Defined Setting:
 
 
 Add user-defined setting

 Call the setting MTLLINKER_FLAGS and set it to -cikernel:
 */

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
  @IBOutlet var previewView: UIView!
  @IBOutlet var containerView: UIView!
  @IBOutlet var combinedImageView: UIImageView!
  @IBOutlet var recordButton: RecordButton!
  var previewLayer: AVCaptureVideoPreviewLayer!
  let session = AVCaptureSession()
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
      /*
       The first line forces the maximum frame rate to be five frames per second. The second line defines the minimum frame rate to be the same. The two lines together require the camera to run at the desired frame rate.
       */
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
    let currentFrame = recordButton.progress * CGFloat(maxFrameCount)
    recordButton.progress = (currentFrame + 1.0) / CGFloat(maxFrameCount)
    if recordButton.progress >= 1.0 {
      stopRecording()
    }
  }
}

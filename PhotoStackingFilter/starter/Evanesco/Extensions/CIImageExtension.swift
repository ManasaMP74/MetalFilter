
import CoreImage

extension CIImage {
  func cgImage() -> CGImage? {
    if cgImage != nil {
      return cgImage
    }
    return CIContext().createCGImage(self, from: extent)
  }
}

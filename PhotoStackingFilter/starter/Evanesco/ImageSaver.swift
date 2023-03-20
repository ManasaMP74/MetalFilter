// used for saving image in file
import CoreImage

struct ImageSaver {
  var count = 0
  let url: URL
  
  init() {
    let uuid = UUID().uuidString
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    url = urls[0].appendingPathComponent(uuid)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
  }
  
  mutating func write(_ image: CIImage, as name: String? = nil) {
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
      return
    }
    let context = CIContext()
    let lossyOption = kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption
    let imgURL: URL
    if let name = name {
      imgURL = url.appendingPathComponent("\(name).jpg")
    } else {
      imgURL = url.appendingPathComponent("\(count).jpg")
    }
    try? context.writeJPEGRepresentation(of: image,
                                         to: imgURL,
                                         colorSpace: colorSpace,
                                         options: [lossyOption: 0.9])
    count += 1
  }
}

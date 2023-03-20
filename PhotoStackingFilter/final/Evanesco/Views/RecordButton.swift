

import UIKit

@IBDesignable
class RecordButton: UIButton {
  var progress: CGFloat = 0.0 {
    didSet {
      DispatchQueue.main.async {
        self.setNeedsDisplay()
      }
    }
  }
  
  override func draw(_ rect: CGRect) {
    // General Declarations
    let context = UIGraphicsGetCurrentContext()!
    
    // Resize to Target Frame
    context.saveGState()    
    
    context.translateBy(x: bounds.minX, y: bounds.minY)
    context.scaleBy(x: bounds.width / 218, y: bounds.height / 218)

    // Color Declarations
    let red = UIColor(red: 0.949, green: 0.212, blue: 0.227, alpha: 1.000)
    let white = UIColor(red: 0.996, green: 1.000, blue: 1.000, alpha: 1.000)
    
    // Variable Declarations
    let expression: CGFloat = -progress * 360
    
    // Button Drawing
    let buttonPath = UIBezierPath(ovalIn: CGRect(x: 26, y: 26, width: 166, height: 166))
    red.setFill()
    buttonPath.fill()
    
    
    // Ring Background Drawing
    let ringBackgroundPath = UIBezierPath(ovalIn: CGRect(x: 8.5, y: 8.5, width: 200, height: 200))
    white.setStroke()
    ringBackgroundPath.lineWidth = 19
    ringBackgroundPath.lineCapStyle = .round
    ringBackgroundPath.stroke()
    
    
    // Progress Ring Drawing
    let progressRingRect = CGRect(x: 8.5, y: 8.5, width: 200, height: 200)
    let progressRingPath = UIBezierPath()
    progressRingPath.addArc(withCenter: CGPoint(x: progressRingRect.midX, y: progressRingRect.midY), radius: progressRingRect.width / 2, startAngle: -90 * CGFloat.pi/180, endAngle: -(expression + 90) * CGFloat.pi/180, clockwise: true)
    
    red.setStroke()
    progressRingPath.lineWidth = 19
    progressRingPath.lineCapStyle = .round
    progressRingPath.stroke()
    
    context.restoreGState()
  }
  
  func resetProgress() {
    progress = 0.0
  }
}

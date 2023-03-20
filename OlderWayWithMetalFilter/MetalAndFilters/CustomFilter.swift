//
//  CustomFilter.swift
//  MetalAndFilters
//
//  Created by rishav kohli on 20/01/22.
//

import Foundation
import CoreImage

class ThreeDyeFilter: CIFilter {
    private let kernel: CIKernel?
    var inputImage: CIImage? // (1)
    var alpha: Float = 1
    
    override init() {
        let url = Bundle.main.url(forResource: "CustomKernal", withExtension: "ci.metallib")
        if let url = url , let data = try? Data(contentsOf: url) {
            do {
                kernel = try? CIKernel(functionName: "dyeInThree", fromMetalLibraryData: data)
            }catch {
                print("canot decode kernel file")
            }
        } else {
            kernel = nil
        }
        
//        let bundlePath = Bundle.main.path(forResource: "RPSCreation", ofType: "bundle")
//        let bundle = Bundle(path: bundlePath ?? "")
//        var code: String? = nil
//                do {
//                    code = try String(
//                        contentsOfFile: bundle?.path(
//                            forResource: "BillBoard",
//                            ofType: "cikernel") ?? "",
//                        encoding: .utf8)
//                } catch {
//                }
         // (2)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var outputImage: CIImage? {
        guard let inputImage = self.inputImage else { return nil }
        let inputExtent = inputImage.extent
        
        let reddish   = CIVector(x: 1, y: 0, z: 0) // (3)
        let greenish  = CIVector(x: 0, y: 1, z: 0)
        let blueish   = CIVector(x: 0, y: 0, z: 1)

        let roiCallback: CIKernelROICallback = { _, rect -> CGRect in  // (4)
            return rect
        }

        return self.kernel?.apply(extent: inputExtent,
                                 roiCallback: roiCallback,
                                 arguments: [inputImage, reddish, greenish, blueish, alpha])  // (5)
    }
}

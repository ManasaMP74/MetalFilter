//
//  Texturable.swift
//  MetalAndFilters
//
//  Created by rishav kohli on 04/02/22.
//

import Foundation
import MetalKit

protocol Texturable {
    var texture: MTLTexture? {get set}
}

extension Texturable {
    
    func setTexture(device:MTLDevice,image:CGImage) -> MTLTexture?{
        
        let textureLoader = MTKTextureLoader(device: device)
        
      //  let textLoaderOptions: [String: NSObject] = [:]
        
        var texture: MTLTexture?
//        if let imageUrl = Bundle.main.url(forResource: imageName, withExtension: "jpeg") {
            do {
              //  texture = try textureLoader.newTe
                texture = try textureLoader.newTexture(cgImage: image, options: nil)
              //  texture = try textureLoader.newTexture(URL: imageUrl, options: nil)
            }
            catch {
                print("texture not created")
            }
//        }
        
        return texture
    }

}

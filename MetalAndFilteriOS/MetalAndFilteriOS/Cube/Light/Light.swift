//
//  Light.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

/*
 https://www.kodeco.com/714-metal-tutorial-with-swift-3-part-4-lighting#toc-anchor-008
 */

import Foundation

struct Light {
  
  var color: (Float, Float, Float)
  var ambientIntensity: Float
    
    /*
     for deffuse light add these
     var direction: (Float, Float, Float)
     var diffuseIntensity: Float
     
     static func size() -> Int {
       return MemoryLayout<Float>.size * 8
     }
       
     func raw() -> [Float] {
       let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity]
       return raw
     }

     */
    
    /*
     var shininess: Float
     var specularIntensity: Float
     
     static func size() -> Int {
       return MemoryLayout<Float>.size * 10
     }
      
     func raw() -> [Float] {
       let raw = [color.0, color.1, color.2, ambientIntensity, direction.0, direction.1, direction.2, diffuseIntensity, shininess, specularIntensity]
       return raw
     }

     */
  
  static func size() -> Int {
    return MemoryLayout<Float>.size * 4
  }
  
  func raw() -> [Float] {
    let raw = [color.0, color.1, color.2, ambientIntensity]
    return raw
  }
}


/*
 in above struct with diffuse,specular and normal light. size function returns MemoryLayout.size * 10 = 40 bytes.
 your Light structure should also be 40 bytes, because that’s exactly the same structure. Right?
 Yes — but that’s not how the GPU works. The GPU operates with memory chunks 16 bytes in size..
 
 so need to replace above struct with
 
 struct Light{
   packed_float3 color;      // 0 - 2
   float ambientIntensity;          // 3
   packed_float3 direction;  // 4 - 6
   float diffuseIntensity;   // 7
   float shininess;          // 8
   float specularIntensity;  // 9
   
   /*
   _______________________
  |0 1 2 3|4 5 6 7|8 9    |
   -----------------------
  |       |       |       |
  | chunk0| chunk1| chunk2|
   */
 };
 
 Even though you have 10 floats, the GPU is still allocating memory for 12 floats — which gives you a mismatch error.

 To fix this crash, you need to increase the Light structure size to match those 3 chunks (12 floats).

 Open Light.swift and change size() to return 12 instead of 10:
 
 static func size() -> Int {
   return MemoryLayout<Float>.size * 12
 }

 */

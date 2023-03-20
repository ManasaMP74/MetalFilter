//
//  vertex.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import Foundation

struct Vertex {
    var x,y,z: Float
    var r,g,b,a: Float
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
}

struct CubeVertex {
    var x,y,z: Float
    var r,g,b,a: Float
    var s,t: Float       // texture coordinates
    var nX,nY,nZ: Float  // normal
    
    func floatBuffer() -> [Float] {
      return [x,y,z,r,g,b,a,s,t,nX,nY,nZ]
    }
}

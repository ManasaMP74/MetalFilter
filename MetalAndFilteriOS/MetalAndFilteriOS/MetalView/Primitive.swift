//
//  Primitive.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

import MetalKit


class Primitive {
    
  //This class method returns a cube.
  class func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
    let allocator = MTKMeshBufferAllocator(device: device)
    let mesh = MDLMesh(boxWithExtent: [size, size, size],
                       segments: [1, 1, 1],
                       inwardNormals: false, geometryType: .triangles,
                       allocator: allocator)
    return mesh
  }
}

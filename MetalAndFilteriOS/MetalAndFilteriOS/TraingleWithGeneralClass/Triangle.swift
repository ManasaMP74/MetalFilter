//
//  Triangle.swift
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

import Foundation
import Metal

class Triangle: Node {
    init(device: MTLDevice) {
        let v0 = Vertex(x: -1, y: 1, z: 0, r: 1, g: 0, b: 0, a: 1)
        let v1 = Vertex(x: -1, y: -1, z: 0, r: 0, g: 1, b: 0, a: 1)
        let v2 = Vertex(x: 1, y: -1, z: 0, r: 0, g: 0, b: 1, a: 1)
        let vertexArray = [v0,v1,v2]
        super.init(name: "Traingle", vertices: vertexArray, device: device)
    }
}

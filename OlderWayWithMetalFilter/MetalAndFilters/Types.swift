//
//  Types.swift
//  MetalAndFilters
//
//  Created by rishav kohli on 31/01/22.
//

import Foundation
import simd

struct VertexInfo {
    
    var position: float3
    var color: float4
    var texture: float2
    
    init(position: float3, color: float4, texture: float2) {
        self.position = position
        self.color = color
        self.texture = texture
    }
    
}

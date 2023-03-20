//
//  Shaders.metal
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basicVertex(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basicFragment() {
    return half4(1.0);
}


//
//  TriangleShader.metal
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

#include <metal_stdlib>
using namespace metal;

struct TraingleVertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct TraingleVertexOut{
    float4 position [[position]];
    float4 color;
};

vertex TraingleVertexOut basicTraingleVertex(const device TraingleVertexIn* vertex_array [[buffer(0)]], unsigned int vid [[ vertex_id ]]) {
    TraingleVertexIn vertexIn = vertex_array[vid];
    TraingleVertexOut vertexOut;
    vertexOut.position = float4(vertexIn.position, 1);
    vertexOut.color = vertexIn.color;
    return vertexOut;
}

fragment half4 basicTraingleFragment(TraingleVertexOut triColor [[stage_in]]) {
    return half4(triColor.color[0], triColor.color[1], triColor.color[2], triColor.color[3]);
}


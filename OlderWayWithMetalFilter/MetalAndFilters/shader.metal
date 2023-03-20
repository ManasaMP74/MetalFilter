//
//  shader.metal
//  MetalAndFilters
//
//  Created by rishav kohli on 31/01/22.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float animatedBy;
};

struct VertexInfo {
    float4 position[[ attribute(0)]];
    float4 color [[ attribute(1)]];
    float2 texturePos [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texturePos;
};

vertex VertexOut vertexShader( const VertexInfo vertexIn [[ stage_in]])
{
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
   // vertexOut.position.x += constants.animatedBy;
    vertexOut.color = vertexIn.color;
    vertexOut.texturePos = vertexIn.texturePos;
    return vertexOut;
//    float4 position = float4(vertices[vertexId], 1);
//    position.x += constants.animatedBy;
//    return position;
}


fragment half4 fragmentShader(VertexOut vertexIn [[stage_in]], texture2d<float> texture [[texture(0)]]){
  //  half gray = (vertexIn.color.x + vertexIn.color.y + vertexIn.color.z) / 3;
    //return half4(vertexIn.color);
    
    constexpr sampler defaultSampler;
    
    float4 color = texture.sample(defaultSampler, vertexIn.texturePos);
    
    return half4(color.r,color.g,color.b,color.a);
    
//    return half4(vertexIn.color);
}

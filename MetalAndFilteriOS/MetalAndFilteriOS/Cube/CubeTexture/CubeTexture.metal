//
//  CubeTexture.metal
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 14/03/23.
//

#include <metal_stdlib>
using namespace metal;


struct TextureVertexIn{
  packed_float3 position;
  packed_float4 color;
  packed_float2 texCoord;
};

struct TextureVertexOut{
  float4 position [[position]];
  float4 color;
  float2 texCoord;
};

struct Uniforms{
  float4x4 modelMatrix;
  float4x4 projectionMatrix;
};

vertex TextureVertexOut basic_textureVertex(
                              const device TextureVertexIn* vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms    [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
  
  float4x4 mv_Matrix = uniforms.modelMatrix;
  float4x4 proj_Matrix = uniforms.projectionMatrix;
  
  TextureVertexIn TextureVertexIn = vertex_array[vid];
  
  TextureVertexOut TextureVertexOut;
  TextureVertexOut.position = proj_Matrix * mv_Matrix * float4(TextureVertexIn.position,1);
  TextureVertexOut.color = TextureVertexIn.color;

  TextureVertexOut.texCoord = TextureVertexIn.texCoord;
  
  return TextureVertexOut;
}


fragment float4 basic_texturefragment(TextureVertexOut interpolated [[stage_in]],
                              texture2d<float>  tex2D     [[ texture(0) ]],
                              sampler           sampler2D [[ sampler(0) ]]) {

    float4 color =  interpolated.color * tex2D.sample(sampler2D, interpolated.texCoord);
    /*
     for Colorizing a Texture
     float4 color =  interpolated.color * tex2D.sample(sampler2D, interpolated.texCoord);
     */
  return color;
}


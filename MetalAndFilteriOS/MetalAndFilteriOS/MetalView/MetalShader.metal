//
//  MetalShader.metal
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 13/03/23.
//

#include <metal_stdlib>
using namespace metal;

//Create a struct VertexIn to describe the vertex attributes that match the vertex descriptor you set up earlier. In this case, just position.
struct VertexIn {
  float4 position [[ attribute(0) ]];
};

//implement a vertex shader, vertex_main, that takes in VertexIn structs and returns vertex positions as float4 types.

//Remember that vertices are indexed in the vertex buffer. The vertex shader gets the current index via the [[ stage_in ]] attribute and unpacks the VertexIn struct cached for the vertex at the current index.
vertex float4 vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant float &timer [[ buffer(1) ]]) {
  float4 position = vertexIn.position;
  position.y += timer;
  return position;
}

fragment float4 fragment_main() {
  return float4(1, 0, 0, 1);
}



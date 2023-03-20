//
//  CubeShader.metal
//  MetalAndFilteriOS
//
//  Created by Manasa M P on 10/03/23.
//

#include <metal_stdlib>
using namespace metal;

struct CubeVertexIn {
    packed_float3 position;
    packed_float4 color;
};


struct CubeVertexOut {
    float4 position [[position]];
    float4 color;
};

struct CubeScaling{
  float4x4 modelMatrix;
};

struct Cube3DModel{
  float4x4 modelMatrix;
  float4x4 projectionMatrix;
};

//basic cube without rotation, transition, scale property
vertex CubeVertexOut cubeVertex(
                                const device  CubeVertexIn* vertexArray [[buffer(0)]],
                                unsigned int vid [[ vertex_id ]]) {
    CubeVertexIn cubeVertexIn = vertexArray[vid];
    CubeVertexOut cubeVertexOut;
    cubeVertexOut.position = float4(cubeVertexIn.position, 1);
    cubeVertexOut.color = cubeVertexIn.color;
    return cubeVertexOut;
}

vertex CubeVertexOut cubeVertexWithMatrix4ForScaling
(const device  CubeVertexIn* vertexArray [[buffer(0)]],
 const device CubeScaling&  cubeScaling [[ buffer(1) ]],
 unsigned int vid [[ vertex_id ]] ) {
    float4x4 mv_Matrix = cubeScaling.modelMatrix;
    CubeVertexIn cubeVertexIn = vertexArray[vid];
    CubeVertexOut cubeVertexOut;
    //To apply the model transformation to a vertex, you simply multiply the vertex position by the model matrix.
    cubeVertexOut.position = mv_Matrix * float4(cubeVertexIn.position, 1);
    cubeVertexOut.color = cubeVertexIn.color;
    return cubeVertexOut;
}

vertex CubeVertexOut cubeVertexWithMatrix4For3D
(const device  CubeVertexIn* vertexArray [[buffer(0)]],
 const device Cube3DModel& cube3D [[ buffer(1) ]],
 unsigned int vid [[ vertex_id ]] ) {
    float4x4 mv_Matrix = cube3D.modelMatrix;
    CubeVertexIn cubeVertexIn = vertexArray[vid];
    
    CubeVertexOut cubeVertexOut;
    
    float4x4 proj_Matrix = cube3D.projectionMatrix;
    
    cubeVertexOut.position = proj_Matrix * mv_Matrix * float4(cubeVertexIn.position,1);
    cubeVertexOut.color = cubeVertexIn.color;
    return cubeVertexOut;
}

fragment half4 cubeFragment(CubeVertexOut cubeColor [[stage_in]]) {
    return half4(cubeColor.color[0], cubeColor.color[1], cubeColor.color[2], cubeColor.color[3]);
}

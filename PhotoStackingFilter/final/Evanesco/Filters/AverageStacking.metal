
#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>

extern "C" { namespace coreimage {
  float4 avgStacking(sample_t currentStack, sample_t newImage, float stackCount) {
    float4 avg = ((currentStack * stackCount) + newImage) / (stackCount + 1.0);
    avg = float4(avg.rgb, 1);
    return avg;
  }
}}

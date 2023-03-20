//
//  CustomKernal.metal
//  MetalAndFilters
//
//  Created by rishav kohli on 20/01/22.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h> // (1)

float3 multiplyColors(float3, float3);

float3 multiplyColors(float3 mainColor, float3 colorMultiplier, float alpha) { // (2)
    float3 color = float3(0,0,0);
    if (colorMultiplier.r < 1) {
        colorMultiplier.r = 1.0 - alpha;
    }
    
    if (colorMultiplier.g < 1) {
        colorMultiplier.g = 1.0 - alpha;
    }
    
    if (colorMultiplier.b < 1) {
        colorMultiplier.b = 1.0 - alpha;
    }
    color.r = mainColor.r * colorMultiplier.r;
    color.g = mainColor.g * colorMultiplier.g;
    color.b = mainColor.b * colorMultiplier.b;
    return color;
};

extern "C"  float4 dyeInThree(coreimage::sampler src, float3 redVector, float3 greenVector, float3 blueVector, float alpha) {

        float2 pos = src.coord();
        float4 pixelColor = src.sample(pos);     // (4)
        
        float3 pixelRGB = pixelColor.rgb;
        
        float3 color = float3(0,0,0);
        if (pos.y < 0.33) {                      // (5)
            color = multiplyColors(pixelRGB, redVector, alpha);
        } else if (pos.y >= 0.33 && pos.y < 0.66) {
            color = multiplyColors(pixelRGB, greenVector, alpha);
        } else {
            color = multiplyColors(pixelRGB, blueVector, alpha);
        }
    

        return float4(color, 1);
    }


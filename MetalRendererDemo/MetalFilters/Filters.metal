//
//  GaussianBlur.metal
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float2 textureCoordinate;
    float2 minBound;
    float2 maxBound;
};

constant float2 quadPositions[4] = {
    { -1.0, -1.0 },
    { -1.0,  1.0 },
    {  1.0, -1.0 },
    {  1.0,  1.0 }
};

struct AspectUniforms {
    float screenAspectRatio;
    float textureAspectRatio;
};

vertex Vertex vertex_main(uint vertexID [[vertex_id]], constant AspectUniforms& uniforms [[buffer(0)]]) {
    Vertex out;
    float2 adjustedTexCoords = quadPositions[vertexID] * 0.5f + 0.5f; // Convert from [-1, 1] to [0, 1] range

    float2 bottomRightPixel;
    if (uniforms.textureAspectRatio > uniforms.screenAspectRatio) {
        // If texture is wider than screen
        float scaleFactor = uniforms.screenAspectRatio / uniforms.textureAspectRatio;
        adjustedTexCoords.y = (adjustedTexCoords.y - 0.5f) / scaleFactor + 0.5f;
        bottomRightPixel = float2(1.0 / scaleFactor, 1.0);
    } else {
        // If texture is taller than screen
        float scaleFactor = uniforms.textureAspectRatio / uniforms.screenAspectRatio;
        adjustedTexCoords.x = (adjustedTexCoords.x - 0.5f) / scaleFactor + 0.5f;
        bottomRightPixel = float2(1.0, 1.0 / scaleFactor);

    }

    adjustedTexCoords.y = 1.0 - adjustedTexCoords.y;  // Flip vertically
    out.position = float4(quadPositions[vertexID], 0.0, 1.0);
    out.textureCoordinate = adjustedTexCoords;
    out.minBound = float2(-adjustedTexCoords.x, -adjustedTexCoords.y);
    out.maxBound = float2(bottomRightPixel.x, bottomRightPixel.y);

    return out;
}

fragment float4 gaussianBlurFragment(Vertex fragmentIn [[ stage_in ]],
                                     texture2d<float, access::sample> texture [[texture(0)]]) {
    float2 offset = fragmentIn.textureCoordinate;
    constexpr sampler qsampler(coord::normalized,
                               address::clamp_to_edge);
    
    float2 minBound = fragmentIn.minBound;
    float2 maxBound = fragmentIn.maxBound;
    if (fragmentIn.textureCoordinate.x < minBound.x || fragmentIn.textureCoordinate.x > maxBound.x ||
        fragmentIn.textureCoordinate.y < minBound.y || fragmentIn.textureCoordinate.y > maxBound.y) {
        return float4(0.0, 0.0, 0.0, 0.0); // Return transparent color for regions outside the valid bounds
    }
    
//    float4 color = texture.sample(qsampler, coordinates);
    float width = texture.get_width();
    float height = texture.get_width();
    float xPixel = (1 / width) * 3;
    float yPixel = (1 / height) * 2;
    
    
    float3 sum = float3(0.0, 0.0, 0.0);
    
    
    // code from https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
    
    // 9 tap filter
    sum += texture.sample(qsampler, float2(offset.x - 4.0*xPixel, offset.y - 4.0*yPixel)).rgb * 0.0162162162;
    sum += texture.sample(qsampler, float2(offset.x - 3.0*xPixel, offset.y - 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x - 2.0*xPixel, offset.y - 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x - 1.0*xPixel, offset.y - 1.0*yPixel)).rgb * 0.1945945946;
    
    sum += texture.sample(qsampler, offset).rgb * 0.2270270270;
    
    sum += texture.sample(qsampler, float2(offset.x + 1.0*xPixel, offset.y + 1.0*yPixel)).rgb * 0.1945945946;
    sum += texture.sample(qsampler, float2(offset.x + 2.0*xPixel, offset.y + 2.0*yPixel)).rgb * 0.1216216216;
    sum += texture.sample(qsampler, float2(offset.x + 3.0*xPixel, offset.y + 3.0*yPixel)).rgb * 0.0540540541;
    sum += texture.sample(qsampler, float2(offset.x + 4.0*xPixel, offset.y + 4.0*yPixel)).rgb * 0.0162162162;
    
    float4 adjusted;
    adjusted.rgb = sum;
//    adjusted.g = color.g;
    adjusted.a = 1;
    return adjusted;
}

// Rec 709 LUMA values for grayscale image conversion
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

fragment float4 grayscaleFragment(Vertex fragmentIn [[stage_in]],
                              texture2d<half, access::sample> inTexture [[texture(0)]]) {
    
    float2 minBound = fragmentIn.minBound;
    float2 maxBound = fragmentIn.maxBound;
    if (fragmentIn.textureCoordinate.x < minBound.x || fragmentIn.textureCoordinate.x > maxBound.x ||
        fragmentIn.textureCoordinate.y < minBound.y || fragmentIn.textureCoordinate.y > maxBound.y) {
        return float4(0.0, 0.0, 0.0, 0.0); // Return transparent color for regions outside the valid bounds
    }
    
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::nearest);
    half4 inColor = inTexture.sample(s, fragmentIn.textureCoordinate);
    half gray = dot(inColor.rgb, kRec709Luma);
    return float4(gray, gray, gray, 1.0);
}

fragment float4 defaultFragment(Vertex fragmentIn [[stage_in]],
                              texture2d<half, access::sample> inTexture [[texture(0)]]) {
    
    float2 minBound = fragmentIn.minBound;
    float2 maxBound = fragmentIn.maxBound;
    if (fragmentIn.textureCoordinate.x < minBound.x || fragmentIn.textureCoordinate.x > maxBound.x ||
        fragmentIn.textureCoordinate.y < minBound.y || fragmentIn.textureCoordinate.y > maxBound.y) {
        return float4(0.0, 0.0, 0.0, 0.0); // Return transparent color for regions outside the valid bounds
    }
    
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::nearest);
    half4 inColor = inTexture.sample(s, fragmentIn.textureCoordinate);
    return float4(inColor.r, inColor.g, inColor.b, 1.0);
}


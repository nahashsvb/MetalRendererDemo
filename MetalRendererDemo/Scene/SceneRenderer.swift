//
//  SceneRenderer.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import Foundation
import MetalKit

struct AspectUniforms {
    var screenAspectRatio: Float
    var textureAspectRatio: Float
}

protocol Renredable {
    func render(_ texture: MTLTexture, with filter: MetalTextureFilter?, to outputTexture: MTLTexture, currentDrawable: CAMetalDrawable, aspect: AspectUniforms)
}

final class SceneRenderer {
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
    }
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue?
    
}

extension SceneRenderer: Renredable {
    
    func render(_ texture: MTLTexture, with filter: MetalTextureFilter?, to outputTexture: MTLTexture, currentDrawable: CAMetalDrawable, aspect: AspectUniforms) {
        
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            return
        }
        
        if let filter = filter {
            filter.apply(to: texture, commandBuffer: commandBuffer, outputTexture: outputTexture, aspect: aspect)
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        } else {
            // No filter, simply copy the input texture to the output
            if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
                let size = MTLSizeMake(texture.width, texture.height, texture.depth)
                blitEncoder.copy(from: texture,
                                 sourceSlice: 0,
                                 sourceLevel: 0,
                                 sourceOrigin: MTLOriginMake(0, 0, 0),
                                 sourceSize: size,
                                 to: outputTexture,
                                 destinationSlice: 0,
                                 destinationLevel: 0,
                                 destinationOrigin: MTLOriginMake(0, 0, 0))
                blitEncoder.endEncoding()
                commandBuffer.present(currentDrawable)
                commandBuffer.commit()
            }
        }
    }
}

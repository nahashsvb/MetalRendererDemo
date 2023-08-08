//
//  OffscreenRenderer.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import UIKit
import Metal
import MetalKit

protocol OffscreenRendererable {
    func renderOffscreen(size: CGSize, sourceTexture: MTLTexture, with filter: MetalTextureFilter) -> UIImage?
}

final class OffscreenRenderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
//    let renderPipelineState: MTLRenderPipelineState
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
    }
}

extension OffscreenRenderer: OffscreenRendererable {
    
    func renderOffscreen(size: CGSize, sourceTexture: MTLTexture, with filter: MetalTextureFilter) -> UIImage? {
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                         width: Int(size.width),
                                                                         height: Int(size.height),
                                                                         mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }

        let aspect = AspectUniforms(screenAspectRatio: 1.0, textureAspectRatio: 1.0)
        filter.apply(to: sourceTexture, commandBuffer: commandBuffer, outputTexture: texture, aspect: aspect)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return UIImage(from: texture)
    }
}

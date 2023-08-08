//
//  Filter.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import Metal
import MetalKit

protocol MetalTextureFilter {
    func apply(to texture: MTLTexture, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture, aspect: AspectUniforms)
}

class GaussianBlurFilter: MetalTextureFilter {
    private var pipelineState: MTLRenderPipelineState!
    
    init(device: MTLDevice) {
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "gaussianBlurFragment")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }
    
    func apply(to texture: MTLTexture, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture, aspect: AspectUniforms) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        var uniforms = aspect
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<AspectUniforms>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}

class GrayscaleFilter: MetalTextureFilter {
    private var pipelineState: MTLRenderPipelineState!
    
    init(device: MTLDevice) {
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "grayscaleFragment")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }

    func apply(to texture: MTLTexture, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture, aspect: AspectUniforms) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        var uniforms = aspect
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<AspectUniforms>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}

class DefaultNoFilter: MetalTextureFilter {
    private var pipelineState: MTLRenderPipelineState!
    
    init(device: MTLDevice) {
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "defaultFragment")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state: \(error)")
        }
    }

    func apply(to texture: MTLTexture, commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture, aspect: AspectUniforms) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        var uniforms = aspect
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<AspectUniforms>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
}


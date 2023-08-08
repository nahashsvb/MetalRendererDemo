//
//  UIImage+MTLTexture.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import MetalKit

extension UIImage {
    static func mtlTexture(named imageName: String) -> MTLTexture? {
        guard let device = MTLCreateSystemDefaultDevice(),
              let image = UIImage(named: imageName),
              let cgImage = image.cgImage else {
            return nil
        }
        
        let loader = MTKTextureLoader(device: device)
        do {
            let texture = try loader.newTexture(cgImage: cgImage, options: nil)
            return texture
        } catch {
            print("Texture creation error: \(error)")
            return nil
        }
    }
}

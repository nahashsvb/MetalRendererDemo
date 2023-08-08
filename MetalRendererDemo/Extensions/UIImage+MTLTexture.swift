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

extension UIImage {
    convenience init?(from texture: MTLTexture) {
        let width = texture.width
        let height = texture.height
        let rowBytes = width * 4 // Assuming RGBA8 format
        
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        texture.getBytes(&pixels, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        // Swap red and blue channels
        for i in stride(from: 0, to: pixels.count, by: 4) {
            let temp = pixels[i]
            pixels[i] = pixels[i + 2]
            pixels[i + 2] = temp
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let dataProvider = CGDataProvider(data: Data(bytes: pixels, count: width * height * 4) as CFData),
              let cgImage = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
}


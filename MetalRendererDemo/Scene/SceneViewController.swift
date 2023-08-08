//
//  SceneViewController.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import MetalKit

struct AspectUniforms {
    var screenAspectRatio: Float
    var textureAspectRatio: Float
}

protocol Filterable {
    func updateWith(texture: MTLTexture, filter: MetalTextureFilter?)
}

final class SceneViewController: UIViewController {
    
    init(device: MTLDevice, filter: MetalTextureFilter?) {
        self.device = device
        self.filter = filter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
    }
    
    private var sceneView: MTKView!
    private var renderer: SceneRenderer!
    private var filter: MetalTextureFilter?
    private var currentTexture: MTLTexture?
    private let device: MTLDevice
    
    private func setupScene() {
        sceneView = MTKView(frame: CGRect.zero)
        sceneView.device = device
        renderer = SceneRenderer(device: device)
        sceneView.delegate = self
        sceneView.framebufferOnly = false
        view.addSubview(sceneView)
        sceneView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SceneViewController: Filterable {
    
    func updateWith(texture: MTLTexture, filter: MetalTextureFilter?) {
        self.currentTexture = texture
        self.filter = filter
        self.sceneView.setNeedsDisplay()
    }
}

extension SceneViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle drawable size changes if needed.
    }

    func draw(in view: MTKView) {
        guard let currentDrawable = sceneView.currentDrawable,
              let texture = currentTexture else {
            return
        }
        
        let screenAspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        let textureAspectRatio = Float(Float(texture.width) / Float(texture.height))
        let uniforms = AspectUniforms(screenAspectRatio: screenAspectRatio, textureAspectRatio: textureAspectRatio)
        renderer.render(texture, with: self.filter, to: currentDrawable.texture, currentDrawable: currentDrawable, aspect: uniforms)
        
    }
}


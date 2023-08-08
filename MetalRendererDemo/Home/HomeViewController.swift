//
//  ViewController.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import UIKit
import MetalKit
import SnapKit

class HomeViewController: UIViewController {
    
    init(device: MTLDevice, filters: [MetalTextureFilter]) {
        self.device = device
        self.filters = filters
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSceneController()
    }
    
    private let sceneViewController: SceneViewController? = nil
    private var device: MTLDevice? = nil
    private var filters: [MetalTextureFilter] = []
    
    private func setupSceneController() {
        guard let device = device else {
            fatalError("device is nil")
        }
        guard let filter = self.filters.first else {
            fatalError("no filters provided")
        }

        let sceneViewController = SceneViewController(device: device,
                                                      filter: filter)
        addChild(sceneViewController)
        view.addSubview(sceneViewController.view)
        sceneViewController.didMove(toParent: self)
        sceneViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(200)
        }
        if let texture = UIImage.mtlTexture(named: "example1") {
            sceneViewController.updateWith(texture: texture, filter: filter)
        }
    }
}


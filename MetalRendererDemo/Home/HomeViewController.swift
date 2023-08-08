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
        setupSceneController()
        setupFiltersController()
    }
    
    private var sceneViewController: SceneViewController? = nil
    private var device: MTLDevice? = nil
    private var filters: [MetalTextureFilter] = []
    private var currentTexture: MTLTexture? = nil
    
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
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(100)
        }
        if let texture = UIImage.mtlTexture(named: "example") {
            self.currentTexture = texture
            sceneViewController.updateWith(texture: texture, filter: filter)
        }
        self.sceneViewController = sceneViewController
    }
    
    private func setupFiltersController() {
        guard let currentTexture = currentTexture else {
            fatalError("currentTexture is nil")
        }
        guard let device = device else {
            fatalError("device is nil")
        }
        
        let filtersController = FiltersViewController(device: device,
                                                      filters: filters,
                                                      currentTexture:currentTexture) { [weak self] filter in
            guard let self = self else { return }
            guard let sceneViewController = sceneViewController else { return }
            guard let texture = self.currentTexture else { return }
            
            sceneViewController.updateWith(texture: texture, filter: filter)
        }
        
        addChild(filtersController)
        view.addSubview(filtersController.view)
        filtersController.didMove(toParent: self)
        filtersController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(100)
        }
    }
}


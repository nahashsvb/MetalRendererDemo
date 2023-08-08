//
//  HomeModule.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import UIKit
import MetalKit

final class HomeModule {
    // MARK: Lifecycle

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Can't create Metal device...")
        }
        let defaultNoFilter = DefaultNoFilter(device: device)
        let grayScaleFilter = GrayscaleFilter(device: device)
        let gaussianBlurFilter = GaussianBlurFilter(device: device)
        let filters: [MetalTextureFilter] = [defaultNoFilter, grayScaleFilter, gaussianBlurFilter]
        let homeViewController = HomeViewController(device: device, filters: filters)
        
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController = navigationController
        self.instanceController = homeViewController
    }

    // MARK: Internal

    private(set) var navigationController: UINavigationController
    private(set) var instanceController: HomeViewController
}


//
//  AppRouter.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import UIKit

/// Root view conroller router
final class AppRouter {
    // MARK: Lifecycle

    init(window: UIWindow) {
        self.window = window
        self.processLaunch()
    }

    // MARK: Private
    private let window: UIWindow
    
    private func processLaunch() {
        self.window.rootViewController = HomeModule().navigationController
        self.window.makeKeyAndVisible()
        
        UIView.transition(
            with: self.window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {},
            completion: { _ in }
        )
    }
}


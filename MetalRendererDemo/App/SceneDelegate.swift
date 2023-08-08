//
//  SceneDelegate.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 07/08/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var router: AppRouter?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.router = AppRouter(window: window)
        self.window = window
    }
}


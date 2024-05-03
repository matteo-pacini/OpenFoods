//
//  UISceneDelegate.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import UIKit

final class SceneDelegate: NSObject, UISceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = .init(windowScene: scene)

        let rootViewController: UIViewController

        if NSClassFromString("XCTest") == nil {
            let viewModel = FoodListViewModel()
            let viewController = FoodListViewController()
            viewController.viewModel = viewModel
            rootViewController = UINavigationController(rootViewController: viewController)
        } else {
            // Display nothing if we're unit testing
            rootViewController = .init()
        }

        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

    }

}

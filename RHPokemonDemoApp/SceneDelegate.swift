//
//  SceneDelegate.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    lazy var coloredPokemonsCoordinator = makeColoredPokemonsCoordinator()
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        window?.rootViewController = coloredPokemonsCoordinator.navigationController
        coloredPokemonsCoordinator.start(animated: false)
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    private func makeColoredPokemonsCoordinator() -> PokemonsCoordinator {
        let coordinator = PokemonsCoordinator.init()
        return coordinator
    }
}


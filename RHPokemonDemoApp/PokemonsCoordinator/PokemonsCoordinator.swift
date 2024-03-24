//
//  ColoredPokemonsCoordinator.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation
import RHInterface
import RHCacheStoreAPI

class PokemonsCoordinator: Coordinator {
    var onCanceled: ((RHInterface.Coordinator) -> Void)?
    var onFinished: ((RHInterface.Coordinator) -> Void)?
    var onFailed: ((RHInterface.Coordinator, Error) -> Void)?
    lazy var router: RHInterface.Router = makeAppRouter()
    var childCoordinators: [RHInterface.Coordinator] = []
    lazy var coloredPokemonsViewController = makeColoredPokemonsViewController()
    var pokemonViewController: PokemonViewController?
    
    // CacheStore
    func start(animated: Bool) {
        navigationController.setNavigationBarHidden(false, animated: false)
        router.push(coloredPokemonsViewController, animated: animated, completion: nil)
    }
}

// MARK: - Factories
private extension PokemonsCoordinator {
    func makeColoredPokemonsViewController() -> PokemonsViewController {
        let vc = PokemonsViewController()
        vc.delegate = self
        return vc
    }
    
    func makePokemonViewController(with pokemonName: String) -> PokemonViewController {
        let vc = PokemonViewController(pokemonName: pokemonName)
        return vc
    }
}

extension PokemonsCoordinator: PokemonsViewControllerDelegate {
    func coloredPokemonsViewController(_ coloredPokemonsViewController: PokemonsViewController, didSelectPokemon name: String) {
        pokemonViewController = makePokemonViewController(with: name)
        router.push(pokemonViewController!, animated: true, completion: nil)
    }
}

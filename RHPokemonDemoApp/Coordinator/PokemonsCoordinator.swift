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
    lazy var allPokemonCardsViewController = makeAllPokemonCardsViewController()
    
    // CacheStore
    func start(animated: Bool) {
        navigationController.setNavigationBarHidden(false, animated: false)
        router.push(allPokemonCardsViewController, animated: animated, completion: nil)
    }
}

// MARK: - Factories
private extension PokemonsCoordinator {
    func makeAllPokemonCardsViewController() -> AllPokemonCardsViewController {
        let vc = AllPokemonCardsViewController()
        vc.delegae = self
        return vc
    }
}

extension PokemonsCoordinator: AllPokemonCardsViewControllerDelegate {
    func allPokemonCardsViewController(_ viewController: AllPokemonCardsViewController, didSelectPokeInfo pokeInfo: PokeInfo, withAllPokeInfos pokeInfos: [PokeInfo]) {
        let vc = PokemonCardDetailViewController.init(allPokemonInfos: pokeInfos, initialPokeInfo: pokeInfo)
        router.push(vc, animated: true, completion: nil)
    }
}

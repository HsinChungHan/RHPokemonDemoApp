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
    lazy var allPokemonCardsViewController = makeAllPokemonCardsViewController()
//    lazy var pokemonCardDetailViewController = makePokemonCardDetailViewController()
    var pokemonViewController: PokemonViewController?
    
    // CacheStore
    func start(animated: Bool) {
        navigationController.setNavigationBarHidden(false, animated: false)
//        router.push(coloredPokemonsViewController, animated: animated, completion: nil)
        router.push(allPokemonCardsViewController, animated: animated, completion: nil)
//        router.push(pokemonCardDetailViewController, animated: animated, completion: nil)
    }
}

// MARK: - Factories
private extension PokemonsCoordinator {
    func makeColoredPokemonsViewController() -> PokemonsViewController {
        let vc = PokemonsViewController()
        vc.delegate = self
        return vc
    }
    
    func makeAllPokemonCardsViewController() -> AllPokemonCardsViewController {
        let vc = AllPokemonCardsViewController()
        vc.delegae = self
        return vc
    }
    
//    func makePokemonCardDetailViewController() -> PokemonCardDetailViewController {
//        let vc = PokemonCardDetailViewController(dataSource: <#PokemonCardDetailViewControllerDataSource#>)
//        return vc
//    }
    
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

extension PokemonsCoordinator: AllPokemonCardsViewControllerDelegate {
    func allPokemonCardsViewController(_ viewController: AllPokemonCardsViewController, didSelectPokeInfo pokeInfo: PokeInfo, withAllPokeInfos pokeInfos: [PokeInfo]) {
        let vc = PokemonCardDetailViewController.init(allPokemonInfos: pokeInfos, initialPokeInfo: pokeInfo)
        router.push(vc, animated: true, completion: nil)
    }
}

//
//  ColoredPokemonsViewModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation

protocol PokemonsViewModelDelegate: AnyObject {
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet blackPokemons: [String])
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet serviceError: PokemonNetworkServiceError)
}

class PokemonsViewModel {
    weak var delegate: PokemonsViewModelDelegate?
    private(set) var pokemonNames = [String]()
    private let useCase: PokemonsUseCaseProtocol
    init(useCase: PokemonsUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func loadAllPokemons() {
        useCase.loadPokemons {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(blackedPokemonsDomain):
                pokemonNames = blackedPokemonsDomain.pokeInfos.map { $0.name }
                self.delegate?.coloredPokemonsViewModel(self, didGet: pokemonNames)
            case let .failure(error):
                self.delegate?.coloredPokemonsViewModel(self, didGet: error)
            }
        }
    }
}

//
//  ColoredPokemonsViewModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation

protocol PokemonsViewModelDelegate: AnyObject {
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet blackPokemons: [PokemonData])
    func coloredPokemonsViewModel(_ coloredPokemonsViewModel: PokemonsViewModel, didGet serviceError: PokemonNetworkServiceError)
}

class PokemonsViewModel {
    weak var delegate: PokemonsViewModelDelegate?
    private(set) var pokemons = [PokemonData]()
    private let useCase: PokemonsUseCaseProtocol
    init(useCase: PokemonsUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func loadAllPokemons() {
        useCase.loadPokemons {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(blackedPokemonsDomain):
                pokemons = blackedPokemonsDomain.pokemons
                self.delegate?.coloredPokemonsViewModel(self, didGet: pokemons)
            case let .failure(error):
                self.delegate?.coloredPokemonsViewModel(self, didGet: error)
            }
        }
    }
}

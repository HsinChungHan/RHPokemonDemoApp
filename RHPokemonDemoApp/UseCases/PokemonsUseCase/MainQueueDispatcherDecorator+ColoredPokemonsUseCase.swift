//
//  MainQueueDispatcherDecorator+PokemonsUseCase.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation
import RHInterface

extension MainQueueDispatcherDecorator: PokemonsUseCaseProtocol where T == PokemonsUseCaseProtocol {
    func loadPokemons(completion: @escaping (Result<PokemonsDomainModel, PokemonNetworkServiceError>) -> Void) {
        decoratee.loadPokemons { [weak self] result in
            self?.dispatchToMainThread { completion(result) }
        }
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void) {
        decoratee.loadPokemon(with: name) { [weak self] result in
            self?.dispatchToMainThread { completion(result) }
        }
    }
    
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        decoratee.downloadPokemonImage(with: id, name: name) { [weak self] result in
            self?.dispatchToMainThread { completion(result) }
        }
    }
}

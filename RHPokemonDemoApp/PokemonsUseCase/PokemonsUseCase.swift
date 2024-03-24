//
//  ColoredPokemonsUseCase.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation

protocol PokemonsUseCaseProtocol {
    func loadPokemons(completion: @escaping (Result<PokemonsDomainModel, PokemonNetworkServiceError>) -> Void)
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void)
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void)
}

final class PokemonsUseCase: PokemonsUseCaseProtocol {
    let repository: PokemonsRepositoryProtocol
    init(repository: PokemonsRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadPokemons(completion: @escaping (Result<PokemonsDomainModel, PokemonNetworkServiceError>) -> Void) {
        repository.loadPokemons(completion: completion)
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void) {
        repository.loadPokemon(with: name, completion: completion)
    }
    
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        repository.downloadPokemonImage(with: id, name: name, completion: completion)
    }
}


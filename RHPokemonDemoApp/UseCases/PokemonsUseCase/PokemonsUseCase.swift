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
        repository.loadAllPokemons(completion: completion)
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void) {
        repository.loadPokemon(with: name, completion: completion)
    }
    
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        repository.downloadPokemonImage(with: id, name: name, completion: completion)
    }
    
    func loadAllPokemonNameAndImage(completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        repository.loadAllPokemons { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(pokemons):
                pokemons.pokeInfos.forEach {
                    self.repository.loadPokemon(with: $0.name) { result in
                        switch result {
                        case let .success(pokemon):
                            self.downloadPokemonImage(with: "\(pokemon.id)", name: "\(pokemon.name)", completion: completion)
                        case .failure:
                            completion(.failure(.networkError))
                        }
                    }
                }
            case .failure:
                completion(.failure(.networkError))
            }
        }
    }
}


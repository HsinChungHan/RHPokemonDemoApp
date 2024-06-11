//
//  ColoredPokemonsRepository.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation

protocol PokemonsRepositoryProtocol {
    func loadAllPokemons(completion: @escaping (Result<PokemonsDomainModel, PokemonNetworkServiceError>) -> Void)
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void)
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void)
}

class PokemonsRepository: PokemonsRepositoryProtocol {
    let networkService: PokenmonsNetworkServiceProtocol
    // TODO: - For old UI style pages, should remove in the future
    let codableStoreService: PokemonsCodableStoreServiceProtocol
    
    // For new style UI
    let actorCodablePokemonStoreService: PokemonActorCodableStoreServiceProtocol
    let actorCodablePokemonsStoreService: PokemonsActorCodableStoreServiceProtocol
    let actorCodableImageDataStoreService: PokemonActorCodableImageStoreServiceProtocol
    init(
        networkService: PokenmonsNetworkServiceProtocol,
        codableStoreService: PokemonsCodableStoreServiceProtocol,
        actorCodableStoreService: PokemonActorCodableStoreServiceProtocol,
        actorCodablePokemonsStoreService: PokemonsActorCodableStoreServiceProtocol,
        actorCodableImageDataStoreService: PokemonActorCodableImageStoreServiceProtocol
    )
    {
        self.networkService = networkService
        self.codableStoreService = codableStoreService
        self.actorCodablePokemonStoreService = actorCodableStoreService
        self.actorCodablePokemonsStoreService = actorCodablePokemonsStoreService
        self.actorCodableImageDataStoreService = actorCodableImageDataStoreService
    }
    
    func loadAllPokemons(completion: @escaping (Result<PokemonsDomainModel, PokemonNetworkServiceError>) -> Void) {
        actorCodablePokemonsStoreService.loadAllPokemons { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(pokemonsDTO):
                completion(.success(.init(from: pokemonsDTO)))
            default:
                self.networkService.loadAllPokemons { result in
                    switch result {
                    case let .success(pokemonsDTO):
                        if let json = JSONEncoder().toJson(from: pokemonsDTO) {
                            self.actorCodablePokemonsStoreService.insertPokemons(with: json) { _ in }
                        }
                        completion(.success(.init(from: pokemonsDTO)))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDomainModel, PokemonNetworkServiceError>) -> Void) {
        actorCodablePokemonStoreService.loadPokemon(with: name) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(dto):
                completion(.success(PokemonDomainModel.init(from: dto)))
            default:
                self.networkService.loadPokemon(with: name) { result in
                    switch result {
                    case let .success(pokemonDTO):
                        if let json = JSONEncoder().toJson(from: pokemonDTO) {
                            self.actorCodablePokemonStoreService.insertPokemon(with: name, json: json) { _ in }
                        }
                        completion(.success(.init(from: pokemonDTO)))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func downloadPokemonImage(with id: String, name: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        actorCodableImageDataStoreService.loadPokemon(with: id, name: name) {[weak self] result in
            guard let self else { return }
            switch result {
            case let .success(data):
                completion(.success(data))
            default:
                self.networkService.downloadPokemonImage(with: id) { result in
                    switch result {
                    case let .success(data):
                        let base64String = data.base64EncodedString()
                        self.actorCodableImageDataStoreService.insertPokemon(with: id, name: name, imageData: data) { _ in }
                        completion(.success(data))
                    default:
                        completion(.failure(.networkError))
                    }
                }
            }
        }
    }
}

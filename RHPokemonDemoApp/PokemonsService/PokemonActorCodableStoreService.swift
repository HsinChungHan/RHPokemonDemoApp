//
//  PokemonActorCodableStoreService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/31.
//

import Foundation
import RHCacheStoreAPI

protocol PokemonActorCodableStoreServiceProtocol {
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonCacheStoreServiceError>) -> Void)
    func insertPokemon(with name: String, json: [String: Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
    func deletePokemon(with name: String, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
}

class PokemonActorCodableStoreService: PokemonActorCodableStoreServiceProtocol {
    let factory = RHCacheStoreAPIImplementationFactory()
    lazy var store = factory.makeActorCodableStore(with: pokemonStoreURL)
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            let result = await store.retrieve(with: name)
            
            switch result {
            case let .found(json):
                guard
                    let json = json as? [String: Any],
                    let pokemonDTO: PokemonDTO = JSONDecoder().toCodableObject(from: json)
                else {
                    completion(.failure(.failureLoad))
                    return
                }
                completion(.success(pokemonDTO))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func insertPokemon(with name: String, json: [String : Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.insert(with: name, json: json)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
    
    func deletePokemon(with name: String, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.delete(with: name)
                completion(.success(()))
            } catch {
                completion(.failure(.failureDeletion))
            }
        }
    }
}

extension PokemonActorCodableStoreService {
    var pokemonStoreURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("pokemon.json")
    }
}

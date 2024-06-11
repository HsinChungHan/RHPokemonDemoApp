//
//  PokemonsActorCodableStoreService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/2/1.
//

import Foundation
import RHCacheStoreAPI

protocol PokemonsActorCodableStoreServiceProtocol {
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonCacheStoreServiceError>) -> Void)
    func insertPokemons(with json: [String: Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
    func deletePokemons(completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
}

class PokemonsActorCodableStoreService: PokemonsActorCodableStoreServiceProtocol {
    let factory = RHCacheStoreAPIImplementationFactory()
    let store: RHActorCacheStoreAPIProtocol
    init() {
        let allPokemonsStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("allPokemons.json")
        
        store = factory.makeActorCodableStore(with: allPokemonsStoreURL)
    }
    
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            let result = await store.retrieve(with: allPokemonsID)
            switch result {
            case let .found(json):
                guard
                    let json = json as? [String: Any],
                    let pokemonsDTO: PokemonsDTO = JSONDecoder().toCodableObject(from: json)
                else {
                    completion(.failure(.failureLoad))
                    return
                }
                completion(.success(pokemonsDTO))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func loadPokemons(from prevEndIndex: Int = 0, perTimeLimit limit: Int = 10, completion: @escaping (Result<PokemonsDTO, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            let result = await store.retrieve(with: allPokemonsID)
            switch result {
            case let .found(json):
                guard
                    let json = json as? [String: Any],
                    let pokemonsDTO: PokemonsDTO = JSONDecoder().toCodableObject(from: json)
                else {
                    completion(.failure(.failureLoad))
                    return
                }
                completion(.success(pokemonsDTO))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func insertPokemons(with json: [String: Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.insert(with: allPokemonsID, json: json)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
    
    func deletePokemons(completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.delete(with: allPokemonsID)
                completion(.success(()))
            } catch {
                completion(.failure(.failureDeletion))
            }
        }
    }
}

extension PokemonsActorCodableStoreService {
    var allPokemonsID: String { "allPokemons" }
}

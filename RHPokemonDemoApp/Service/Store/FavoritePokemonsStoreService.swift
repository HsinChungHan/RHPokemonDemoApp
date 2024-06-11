//
//  FavoritePokemonsStoreService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/6/11.
//

import Foundation
import RHCacheStoreAPI

protocol FavoritePokemonsStoreServiceProtocol {
    func loadAll(completion: @escaping (Result<FavoritePokemonsDTO, PokemonCacheStoreServiceError>) -> Void)
    func insert(with json: [String: Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
}

class FavoritePokemonsStoreService: FavoritePokemonsStoreServiceProtocol {
    let factory = RHCacheStoreAPIImplementationFactory()
    let store: RHActorCacheStoreAPIProtocol
    init() {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("favoritePokemons.json")
        store = factory.makeActorCodableStore(with: storeURL)
    }
    
    func loadAll(completion: @escaping (Result<FavoritePokemonsDTO, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            let result = await store.retrieve(with: fieldName)
            
            switch result {
            case let .found(json):
                guard
                    let json = json as? [String: Any],
                    let favoritesDTO: FavoritePokemonsDTO = JSONDecoder().toCodableObject(from: json)
                else {
                    completion(.failure(.failureLoad))
                    return
                }
                completion(.success(favoritesDTO))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func insert(with json: [String: Any], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
               try await store.insert(with: fieldName, json: json)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
}

private extension FavoritePokemonsStoreService {
    var fieldName: String {
        "pokemons"
    }
}

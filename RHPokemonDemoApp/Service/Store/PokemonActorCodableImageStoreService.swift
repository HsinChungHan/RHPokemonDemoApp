//
//  PokemonActorCodableImageStoreService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/2/1.
//

import Foundation
import RHCacheStoreAPI

protocol PokemonActorCodableImageStoreServiceProtocol {
    func loadPokemon(with id: String, name: String, completion: @escaping (Result<Data, PokemonCacheStoreServiceError>) -> Void)
    func insertPokemon(with id: String, name: String, imageData: Data, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
    func deletePokemon(with id: String, name: String, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)
}

class PokemonActorCodableImageStoreService: PokemonActorCodableImageStoreServiceProtocol {
    let factory = RHCacheStoreAPIImplementationFactory()
    let store: RHActorImageDataCacheStoreAPIProtocol
    
    init() {
        let pokemonImageStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        store = factory.makeActorCodableImageDataStore(with: pokemonImageStoreURL)
    }
    func loadPokemon(with id: String, name: String, completion: @escaping (Result<Data, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            let fileName = "\(id)_\(name)"
            let result = await store.retrieve(with: fileName)
            switch result {
            case .empty:
                completion(.failure(.failureLoad))
            case let .found(data):
                completion(.success(data))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func insertPokemon(with id: String, name: String, imageData: Data, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
                let fileName = "\(id)_\(name)"
                try await store.insert(with: fileName, imageData: imageData)
                completion(.success(()))
            } catch {
                completion(.failure(.failureInsertion))
            }
        }
    }
    
    func deletePokemon(with id: String, name: String, completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        Task {
            do {
                let fileName = "\(id)_\(name)"
                try await store.delete(with: fileName)
                completion(.success(()))
            } catch {
                completion(.failure(.failureDeletion))
            }
        }
    }
}

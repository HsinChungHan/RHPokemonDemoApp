//
//  FavoritePokemonsRepository.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/6/11.
//

import Foundation
protocol FavoritePokemonsRepositoryProtocol {
    func loadFavoritePokes(completion: @escaping (Result<FavoritePokemonsDomainModel, PokemonCacheStoreServiceError>) -> Void)
    func updateFavoritePokes(withIDs ids: [Int], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void)}

class FavoritePokemonsRepository: FavoritePokemonsRepositoryProtocol {
    let storeService: FavoritePokemonsStoreServiceProtocol
    
    init(storeService: FavoritePokemonsStoreServiceProtocol) {
        self.storeService = storeService
    }
    
    func loadFavoritePokes(completion: @escaping (Result<FavoritePokemonsDomainModel, PokemonCacheStoreServiceError>) -> Void) {
        storeService.loadAll { result in
            switch result {
            case let .success(dto):
                let favoritePokesDomainModel = FavoritePokemonsDomainModel.init(from: dto)
                completion(.success(favoritePokesDomainModel))
            default:
                completion(.failure(.failureLoad))
            }
        }
    }
    
    func updateFavoritePokes(withIDs ids: [Int], completion: @escaping (Result<Void, PokemonCacheStoreServiceError>) -> Void) {
        let json: [String: Any] = ["ids": ids]
        storeService.insert(with: json) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            default:
                completion(.failure(.failureInsertion))
            }
        }
    }
}

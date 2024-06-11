//
//  PokemonsCodableStoreService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/28.
//

import Foundation
import RHCacheStoreAPI

enum PokemonsCodableStoreServiceError: Error {
    case jsonError
    case failureToLoadError
    case failureToSaveError
}

protocol PokemonsCodableStoreServiceProtocol {
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonsCodableStoreServiceError>) -> Void)
    func saveAllPokemons(with pokemonsDTO: PokemonsDTO, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void)
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonsCodableStoreServiceError>) -> Void)
    func savePokemon(with pokemonDTO: PokemonDTO, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void)
    func downloadPokemonImage(with id: String, completion: @escaping (Result<Data, PokemonsCodableStoreServiceError>) -> Void)
    func savePokemonImage(withPicture data: Data, pictureUrl: URL, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void)
}

class PokemonsCodableStoreService: PokemonsCodableStoreServiceProtocol {
    let pokemonStore: RHCacheStoreAPIProtocol
    let pokemonsStore: RHCacheStoreAPIProtocol
    let pokemonPictureStore: RHCacheStoreAPIProtocol

    init() {
        let pokemonStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("pokemon.store")
        
        let pokemonsStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("pokemons.store")
        
        let pokemonPictureStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("pokemon_picture")
        
        pokemonStore = RHCacheStoreAPIImplementationFactory().makeCodableStore(with: pokemonStoreURL, expiryTimeInterval: nil)
        
        pokemonsStore = RHCacheStoreAPIImplementationFactory().makeCodableStore(with: pokemonsStoreURL, expiryTimeInterval: nil)
        
        pokemonPictureStore = RHCacheStoreAPIImplementationFactory().makeCodableStore(with: pokemonPictureStoreURL, expiryTimeInterval: nil)
    }
    
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonsCodableStoreServiceError>) -> Void) {
        pokemonsStore.retrieve(with: "pokemons") { result in
            switch result {
            case let .success(data):
                do {
                    let pokemonsDTO = try JSONDecoder().decode(PokemonsDTO.self, from: data)
                    completion(.success(pokemonsDTO))
                } catch {
                    completion(.failure(.jsonError))
                }
            case .failure(_):
                completion(.failure(.failureToLoadError))
            }
        }
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonsCodableStoreServiceError>) -> Void) {
        pokemonStore.retrieve(with: name) { result in
            switch result {
            case let .success(data):
                do {
                    let pokemonDTO = try JSONDecoder().decode(PokemonDTO.self, from: data)
                    completion(.success(pokemonDTO))
                } catch {
                    completion(.failure(.jsonError))
                }
            case .failure(_):
                completion(.failure(.failureToLoadError))
            }
        }
    }
    
    func downloadPokemonImage(with id: String, completion: @escaping (Result<Data, PokemonsCodableStoreServiceError>) -> Void) {
        pokemonPictureStore.retrieve(with: id) { result in
            switch result {
            case let .success(data):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.failureToLoadError))
            }
        }
    }
    
    func saveAllPokemons(with pokemonsDTO: PokemonsDTO, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void) {
        do {
            let data = try JSONEncoder().encode(pokemonsDTO)
            pokemonsStore.insert(with: "pokemons", data: data) { result in
                switch result {
                case .success(()):
                    completion(.success(()))
                case .failure(_):
                    completion(.failure(.failureToSaveError))
                }
            }
        } catch {
            completion(.failure(.jsonError))
        }
        
    }
    
    func savePokemon(with pokemonDTO: PokemonDTO, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void) {
        do {
            let id = pokemonDTO.name
            let data = try JSONEncoder().encode(pokemonDTO)
            pokemonsStore.insert(with: id, data: data) { result in
                switch result {
                case .success(()):
                    completion(.success(()))
                case .failure(_):
                    completion(.failure(.failureToSaveError))
                }
            }
        } catch {
            completion(.failure(.jsonError))
        }
    }
    
    func savePokemonImage(withPicture data: Data, pictureUrl: URL, completion: @escaping (Result<Void, PokemonsCodableStoreServiceError>) -> Void) {
        pokemonPictureStore.insert(with: pictureUrl.absoluteString, data: data) { result in
            switch result {
            case .success(()):
                completion(.success(()))
            case .failure(_):
                completion(.failure(.failureToSaveError))
            }
        }
    }
}

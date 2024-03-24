//
//  PokenmonPropertyService.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/25.
//

import Foundation
import RHNetworkAPI



protocol PokenmonsNetworkServiceProtocol {
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonNetworkServiceError>) -> Void)
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonNetworkServiceError>) -> Void)
    func downloadPokemonImage(with id: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void)
}

class PokemonsNetworkRemoteService: PokenmonsNetworkServiceProtocol {
    let factory = RHNetworkAPIImplementationFactory()
    lazy var dataNetworkAPI = factory.makeNonCacheClient(with: .init(string: "https://pokeapi.co/api/v2")!)
/*svg
    lazy var svgImageNetworkAPI = factory.makeNonCacheClient(with: .init(string: "https://raw.githubusercontent.com/PokeAPI")!)
    let path = "/sprites/master/sprites/pokemon/other/dream-world/\(id).svg"
 */

    lazy var imageNetworkAPI = factory.makeNonCacheClient(with: .init(string: "https://raw.githubusercontent.com")!, headers: headers)
    
    func loadAllPokemons(completion: @escaping (Result<PokemonsDTO, PokemonNetworkServiceError>) -> Void) {
        let path = "/pokemon"
        let queries: [URLQueryItem] = [
            .init(name: "limit", value: "1302")
        ]
        dataNetworkAPI.get(path: path, queryItems: queries) { result in
            switch result {
            case let .success(data, _):
                do {
                    let pokemonsDTO = try JSONDecoder().decode(PokemonsDTO.self, from: data)
                    completion(.success(pokemonsDTO))
                } catch {
                    completion(.failure(.jsonError))
                }
            case .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
    
    func loadPokemon(with name: String, completion: @escaping (Result<PokemonDTO, PokemonNetworkServiceError>) -> Void) {
        let path = "/pokemon/\(name)"
        dataNetworkAPI.get(path: path, queryItems: []) { result in
            switch result {
            case let .success(data, _):
                do {
                    let pokemonDTO = try JSONDecoder().decode(PokemonDTO.self, from: data)
                    completion(.success(pokemonDTO))
                } catch {
                    completion(.failure(.jsonError))
                }
            case .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
    
    func downloadPokemonImage(with id: String, completion: @escaping (Result<Data, PokemonNetworkServiceError>) -> Void) {
        let path = "/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/\(id).png"
        imageNetworkAPI.get(path: path, queryItems: []) { result in
            switch result {
            case let .success(data, _):
                completion(.success(data))
            case .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
}

extension PokemonsNetworkRemoteService {
    var headers: [String : String] {
        [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36"
        ]
    }
}

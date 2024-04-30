//
//  PokeColorDTO.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/25.
//

import Foundation

struct PokemonsDTO: Codable {
    struct Result: Codable {
        let name: String
        let url: String
        

        enum CodingKeys: String, CodingKey {
            case name
            case url
        }
        
        
    }
    
    let count: Int
    let results: [Result]
    
    enum CodingKeys: String, CodingKey {
        case count
        case results
    }
}

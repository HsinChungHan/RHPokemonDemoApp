//
//  PokeColorDomainModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/25.
//

import Foundation

struct PokemonData {
    let name: String
    let url: String
}

struct PokemonsDomainModel {
    let pokemons: [PokemonData]
    
    init(from dto: PokemonsDTO) {
        self.pokemons = dto.results.map { PokemonData(name: $0.name, url: $0.url) }
    }
}

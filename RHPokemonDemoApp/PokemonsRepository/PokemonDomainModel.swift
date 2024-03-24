//
//  PokemonDomainModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/26.
//

import Foundation

struct PokemonDomainModel {
    let name: String
    let id: Int
    let weight: Int
    let height: Int
    let imgaeUrl: URL?
    // Mapper
    init(from dto: PokemonDTO) {
        self.name = dto.name
        self.id = dto.id
        self.weight = dto.weight
        self.height = dto.height
        self.imgaeUrl = URL.init(string: dto.sprites.other.home.frontShiny ?? "")
    }
}

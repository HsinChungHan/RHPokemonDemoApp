//
//  FavoritePokemonsDomainModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/6/11.
//

import Foundation
struct FavoritePokemonsDomainModel {
    let ids: [Int]
    
    // Mapper
    init(from dto: FavoritePokemonsDTO) {
        self.ids = dto.ids
    }
}

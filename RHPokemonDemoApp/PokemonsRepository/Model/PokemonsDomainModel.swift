//
//  PokeColorDomainModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/25.
//

import Foundation

struct PokeInfo: Equatable {
    let name: String
    let uid: String
    
    static func == (lhs: PokeInfo, rhs: PokeInfo) -> Bool {
        lhs.uid == rhs.uid
    }
}



struct PokemonsDomainModel {
    var pokeInfos: [PokeInfo] {
        pokemonsDTO.results.map {
            .init(name: $0.name, uid: "\(extractLastNumber(from: $0.url) ?? -1)")
        }
    }
    let pokemonsDTO: PokemonsDTO
    init(from dto: PokemonsDTO) {
        pokemonsDTO = dto
    }
    
    private func extractLastNumber(from url: String) -> Int? {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return nil
        }

        let pathComponents = url.pathComponents
        let nonEmptyComponents = pathComponents.filter { !$0.isEmpty }
        guard let lastNumberString = nonEmptyComponents.last else {
            print("No numeric component found in the URL")
            return nil
        }
        return Int(lastNumberString)
    }
}

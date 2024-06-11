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
    
    // gogolook feature
    var isFavorite = false
    // Mapper
    init(from dto: PokemonDTO) {
        self.name = dto.name
        self.id = dto.id
        self.weight = dto.weight
        self.height = dto.height
        self.imgaeUrl = URL.init(string: dto.sprites.other.home.frontShiny ?? "")
    }
    
    var meterHeight: String {
        formatToDecimalPlace(value: Double(height) / Double(10)) + " m"
    }
    
    var kgWeight: String {
        formatToDecimalPlace(value: Double(weight) / Double(10)) + " kg"
    }
}

private extension PokemonDomainModel {
    func formatToDecimalPlace(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

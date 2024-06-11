//
//  CardModel.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/17.
//

import Foundation

struct PokeCellModel: Equatable {
    let name: String
    let uid: String
    var imageData: Data?
    
    init(fromPokeInfo pokeInfo: PokeInfo) {
        name = pokeInfo.name
        uid = pokeInfo.uid
    }
    
    init(name: String, uid: String, imageData: Data? = nil) {
        self.name = name
        self.uid = uid
        self.imageData = imageData
    }
    
    static func == (lhs: PokeCellModel, rhs: PokeCellModel) -> Bool {
        return lhs.uid == rhs.uid
    }
}

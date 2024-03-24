//
//  PokemonCacheStoreServiceError.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/2/1.
//

import Foundation

enum PokemonCacheStoreServiceError: Error {
    case failureInsertion
    case failureLoad
    case failureDeletion
}

//
//  JsonDecoder+jsonToCodableObject.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/31.
//

import Foundation

extension JSONDecoder {
    func toCodableObject<T: Codable>(from json: [String: Any]) -> T? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        else { return nil }
        return try? decode(T.self, from: jsonData)
    }
}

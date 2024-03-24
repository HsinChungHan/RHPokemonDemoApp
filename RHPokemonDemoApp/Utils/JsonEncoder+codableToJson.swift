//
//  JsonEncoder+codableToJson.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/1/31.
//

import Foundation

import Foundation

extension JSONEncoder {
    func toJson<T: Codable>(from object: T) -> [String: Any]? {
        do {
            let data = try self.encode(object)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
}

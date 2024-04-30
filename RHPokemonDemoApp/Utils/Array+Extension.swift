//
//  Array+Extension.swift
//  RHPokemonDemoApp
//
//  Created by Chung Han Hsin on 2024/4/19.
//

import Foundation
extension Array {
    func elements(at ranges: [ClosedRange<Int>]) -> [Element] {
        var result: [Element] = []
        for range in ranges {
            // 確保範圍在陣列的有效索引內
            if range.lowerBound >= 0 && range.upperBound < self.count {
                result.append(contentsOf: self[range])
            }
        }
        return result
    }
}

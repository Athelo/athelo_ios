//
//  Double+Formatting.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import Foundation

extension Array where Element == Double {
    func toRangeDescription(with unit: UnitNameData) -> String {
        guard !isEmpty else {
            return "0 \(unit.plural)"
        }
        
        guard let minValue = self.min(),
              let maxValue = self.max() else {
            return "0 \(unit.plural)"
        }
        
        return [Int(minValue), Int(maxValue)].toRangeDescription(with: unit)
    }
}

extension Array where Element == Int {
    func toRangeDescription(with unit: UnitNameData) -> String {
        guard !isEmpty else {
            return "0 \(unit.plural)"
        }
        
        guard let minValue = self.min(),
              let maxValue = self.max() else {
            return "0 \(unit.plural)"
        }
        
        if minValue != maxValue {
            return "\(minValue) - \(maxValue) \(unit.plural)"
        } else {
            return "\(minValue) \(unit.unitName(for: minValue))"
        }
    }
}

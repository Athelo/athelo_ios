//
//  UnitNameData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

struct UnitNameData {
    let plural: String
    let short: String
    let singular: String
    
    func unitName(for value: Int) -> String {
        abs(value) == 1 ? singular : plural
    }
    
    func unitName(for value: Double, rule: FloatingPointRoundingRule = .towardZero) -> String {
        unitName(for: Int(value.rounded(rule)))
    }
}

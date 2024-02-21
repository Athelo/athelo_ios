//
//  TimeInterval+Formatting.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

extension TimeInterval {
    func toSleepTimeString(unitsStyle: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.unitsStyle = unitsStyle
        
        var result = formatter.string(from: self) ?? "0m"
        if unitsStyle == .abbreviated, result.hasSuffix("min") {
            result = result.replacingOccurrences(of: "min", with: "m")
        }
        if unitsStyle == .positional, !result.contains(":") {
            result.insert(contentsOf: "0:", at: result.startIndex)
        }
        
        return result
    }
}



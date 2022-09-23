//
//  FeelingScale.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

enum FeelingScale: String {
    case bad
    case middling
    case good
    
    init(generalFeeling: Int) {
        if generalFeeling <= 25 {
            self = .bad
        } else if generalFeeling > 75 {
            self = .good
        } else {
            self = .middling
        }
    }
    
    init(value: Float, within range: ClosedRange<Float> = 1...100) {
        let difference = range.upperBound - range.lowerBound
        if range.lowerBound...(range.lowerBound + difference / 4.0) ~= value {
            self = .good
        } else if (range.upperBound - difference / 4.0)...range.upperBound ~= value {
            self = .bad
        } else {
            self = .middling
        }
    }
    
    var descriptor: String {
        "feeling.\(rawValue)".localized()
    }
    
    var emoji: String {
        switch self {
        case .bad:
            return "😓"
        case .middling:
            return "🤕"
        case .good:
            return "😊"
        }
    }
    
    func displayableValue(within range: ClosedRange<Float> = 1...100) -> Float {
        switch self {
        case .bad:
            return range.upperBound
        case .good:
            return range.lowerBound
        case .middling:
            return (range.upperBound - range.lowerBound) / 2.0
        }
    }
    
    func toGeneralFeeling(within range: ClosedRange<Int> = 1...100) -> Int {
        switch self {
        case .good:
            return range.upperBound
        case .middling:
            return Int(ceil(Double(range.upperBound - range.lowerBound) / 2.0))
        case .bad:
            return range.lowerBound
        }
    }
}

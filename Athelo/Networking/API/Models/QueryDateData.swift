//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Foundation

public enum QueryDateData {
    case exactMonth(Int)
    case exactYear(Int)
    case lowerBound(Date, canBeEqual: Bool)
    case specificDates([Date])
    case upperBound(Date, canBeEqual: Bool)
    
    func toQueryItem(for fieldName: String, format: String) -> URLQueryItem? {
        switch self {
        case .exactMonth(let month):
            return .init(name: "\(fieldName)__month", value: "\(month)")
        case .exactYear(let year):
            return .init(name: "\(fieldName)__year", value: "\(year)")
        case .lowerBound(let date, let canBeEqual):
            return .init(name: "\(fieldName)__gt\(canBeEqual ? "e" : "")", value: date.toString(.custom(format)))
        case .specificDates(let dates):
            guard !dates.isEmpty else {
                return nil
            }
            
            return .init(name: "\(fieldName)__in", value: dates.map({ $0.toString(.custom(format)) }).joined(separator: ","))
        case .upperBound(let date, let canBeEqual):
            return .init(name: "\(fieldName)__lt\(canBeEqual ? "e" : "")", value: date.toString(.custom(format)))
        }
    }
}

public extension Collection where Element == QueryDateData {
    func toQueryItems(for fieldName: String, format: String) -> [URLQueryItem] {
        compactMap({ $0.toQueryItem(for: fieldName, format: format) })
    }
}

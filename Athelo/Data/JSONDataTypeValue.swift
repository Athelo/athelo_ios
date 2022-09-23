//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

enum JSONDataTypeValue: Decodable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case array([JSONDataTypeValue])
    case dict([String: JSONDataTypeValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let arrayValue = try? container.decode([JSONDataTypeValue].self) {
            self = .array(arrayValue)
        } else if let dictValue = try? container.decode([String: JSONDataTypeValue].self) {
            self = .dict(dictValue)
        } else {
            self = .null
        }
    }
}

extension Array where Element == JSONDataTypeValue {
    func jsonArray() -> [Any] {
        map { value -> Any in
            switch value {
            case .array(let array):
                return array.jsonArray()
            case .bool(let bool):
                return bool
            case .dict(let dict):
                return dict.jsonDict()
            case .double(let double):
                return double
            case .int(let int):
                return int
            case .null:
                return NSNull()
            case .string(let string):
                return string
            }
        }
    }
}

extension Dictionary where Key == String, Value == JSONDataTypeValue {
    func jsonDict() -> [String: Any] {
        mapValues({ value -> Any in
            switch value {
            case .array(let array):
                return array.jsonArray()
            case .bool(let bool):
                return bool
            case .dict(let dict):
                return dict.jsonDict()
            case .double(let double):
                return double
            case .int(let int):
                return int
            case .null:
                return NSNull()
            case .string(let string):
                return string
            }
        })
    }
}

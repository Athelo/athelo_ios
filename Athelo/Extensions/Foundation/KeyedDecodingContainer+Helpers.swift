//
//  KeyedDecodingContainer+Helpers.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation
import SwiftDate

extension KeyedDecodingContainer {
    /// Attempts to decode a value automatically unwrapping into a valid type, if possible.
    ///
    /// - Parameter key: Key under which decoding attempt will be made.
    /// - Throws: Throws the same way as any decode(_:forKey:) method.
    /// - Returns: Valid object.
    func decodeValue<T: Decodable>(forKey key: Self.Key) throws -> T {
        try decode(T.self, forKey: key)
    }

    /// Attempts to decode a value automatically unwrapping into a valid type, if possible.
    ///
    /// - Parameter key: Key under which decoding attempt will be made.
    /// - Throws: Throws the same way as any decodeIfPresent(_:forKey:) method.
    /// - Returns: Valid object, if present.
    func decodeValueIfPresent<T: Decodable>(forKey key: Self.Key) throws -> T? {
        try decodeIfPresent(T.self, forKey: key)
    }
    
    func decodeDate(forKey key: Self.Key, format: String) throws -> Date {
        return try decodeDate(forKey: key, format: format, region: .ISO)
    }
    
    func decodeDate(forKey key: Self.Key, format: String, region: Region) throws -> Date {
        let dateString: String = try decodeValue(forKey: key)
        guard let date = Date(dateString, format: format, region: region) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid date format of \(format) for value \(dateString).")
        }
        
        return date
    }
    
    func decodeDateIfPresent(for key: Self.Key, format: String) throws -> Date? {
        return try decodeDateIfPresent(for: key, format: format, region: .ISO)
    }
    
    func decodeDateIfPresent(for key: Self.Key, format: String, region: Region) throws -> Date? {
        guard let dateString: String = try decodeValueIfPresent(forKey: key) else {
            return nil
        }
        
        return Date(dateString, format: format, region: region)
    }
    
    func decodeISODate(for key: Self.Key) throws -> Date{
        let dateString: String = try decodeValue(forKey: key)
        guard let date = dateString.toISODate()?.date else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Invalid ISO date format for value \(dateString).")
        }
        
        return date
    }
    
    func decodeISODateIfPresent(for key: Self.Key) throws -> Date? {
        guard let dateString: String = try decodeValueIfPresent(forKey: key) else {
            return nil
        }
        
        return dateString.toISODate()?.date
    }
}

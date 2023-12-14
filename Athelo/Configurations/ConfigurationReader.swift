//
//  ConfigurationReader.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/12/2022.
//

import Foundation

final class ConfigurationReader {
    // MARK: - Constants
    enum ConfigError: Error {
        case invalidType
        case missingValue
    }
    
    enum Key: String {
        case apiIdentifier = "Config-APIIdentifier"
        case apiURL = "Config-APIURL"
        case chatIdentifier = "Config-ChatIdentifier"
        case chatURL = "Config-ChatURL"
    }
    
    // MARK: - Properties
    private static let reader = ConfigurationReader()
    
    private var store: [Key: Any] = [:]
    
    // MARK: - Public API
    static func configurationValue<T>(for key: Key) throws -> T {
        if reader.store[key] == nil {
            guard let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else {
                throw ConfigError.missingValue
            }
            
            reader.store[key] = value
        }
        
        guard let expectedValue = reader.store[key] as? T else {
            throw ConfigError.invalidType
        }
        
        return expectedValue
    }
}

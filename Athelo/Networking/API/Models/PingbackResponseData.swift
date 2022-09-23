//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public struct PingbackResponseData: Decodable {
    public let detail: String
    
    private enum CodingKeys: String, CodingKey {
        case detail
        case details
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let details: String = try? container.decodeValue(forKey: .details) {
                self.detail = details
            } else {
                self.detail = try container.decodeValue(forKey: .detail)
            }
        } else {
            let container = try decoder.singleValueContainer()
            
            self.detail = try container.decode(String.self)
        }
    }
}

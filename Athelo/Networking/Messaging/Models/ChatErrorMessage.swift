//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatErrorMessage: Decodable, MessagingIncomingChatMetadata {
    public let message: String
    public let errorCode: Int
    public let extra: [String: Any]?

    private enum CodingKeys: String, CodingKey {
        case message, extra
        case errorCode = "error_code"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.message = try container.decodeValue(forKey: .message)
        self.errorCode = try container.decodeValue(forKey: .errorCode)
        
        if let extra: [String: JSONDataTypeValue] = try? container.decodeValue(forKey: .extra) {
            self.extra = extra
        } else {
            self.extra = nil
        }
    }
}

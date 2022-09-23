//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatSystemMessage: Decodable, Hashable, MessagingIncomingChatMetadata {
    public let message: String
    public let roomIdentifier: String
    public let timestamp: Int64

    private enum CodingKeys: String, CodingKey {
        case message
        case roomIdentifier = "chat_room_identifier"
        case timestamp = "message_timestamp_identifier"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.message = try container.decodeValue(forKey: .message)
        self.roomIdentifier = try container.decodeValue(forKey: .roomIdentifier)
        self.timestamp = try container.decodeValue(forKey: .timestamp)
    }
}

extension MessagingChatSystemMessage: MessagingIncomingChatMessageIdentifiableMetadata {
    public var incomingChatRoomID: String {
        roomIdentifier
    }

    public var incomingChatMessageID: Int64 {
        timestamp
    }

    public var incomingChatMessageText: String? {
        message
    }
}

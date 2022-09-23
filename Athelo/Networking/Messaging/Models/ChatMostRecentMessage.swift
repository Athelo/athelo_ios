//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatMostRecentMessage: Decodable, Hashable {
    public let chatRoomIdentifier: String
    public let hasUnreadMessages: Bool
    public let text: String?
    public let timestamp: Int64

    private enum CodingKeys: String, CodingKey {
        case chatRoomIdentifier = "chat_room_identifier"
        case hasUnreadMessages = "has_unread_messages"
        case text = "last_message_text"
        case timestamp = "message_timestamp_identifier"
    }

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let timestamp: Int64 = try? container.decodeValue(forKey: .timestamp) {
                self.timestamp = timestamp
            } else {
                let timestamp: String = try container.decodeValue(forKey: .timestamp)
                guard let timestampValue = Int64(timestamp) else {
                    throw DecodingError.typeMismatch(Int64.self, DecodingError.Context.init(codingPath: [CodingKeys.timestamp], debugDescription: "Cannot convert string value under .payload key into Int64."))
                }

                self.timestamp = timestampValue
            }

            self.chatRoomIdentifier = try container.decodeValue(forKey: .chatRoomIdentifier)
            self.hasUnreadMessages = try container.decodeValue(forKey: .hasUnreadMessages)
            self.text = try container.decodeValue(forKey: .text)
        } catch let error {
            throw error
        }
    }
}

extension MessagingChatMostRecentMessage: MessagingIncomingChatMessageIdentifiableMetadata {
    public var incomingChatRoomID: String {
        chatRoomIdentifier
    }

    public var incomingChatMessageID: Int64 {
        timestamp
    }

    public var incomingChatMessageText: String? {
        text
    }
}

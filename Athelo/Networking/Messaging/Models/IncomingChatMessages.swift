//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public protocol MessagingIncomingChatMetadata: Decodable {
    /* ... */
}

public protocol MessagingIncomingChatRoomIdentifiableMetadata: MessagingIncomingChatMetadata {
    var incomingChatRoomID: String { get }
}

public protocol MessagingIncomingChatMessageIdentifiableMetadata: MessagingIncomingChatRoomIdentifiableMetadata {
    var incomingChatMessageID: Int64 { get }
    var incomingChatMessageText: String? { get }
}

public struct MessagingIncomingChatSocketMessage: Decodable {
    public enum MessageType: String, Decodable {
        case error = "ERROR"
        case history = "GET_HISTORY"
        case lastMessage = "GET_LAST_CHAT_ROOM_MESSAGE"
        case messageRead = "SET_LAST_MESSAGE_READ"
        case messagesRead = "GET_LAST_MESSAGES_READ"
        case routable = "ROUTABLE"
        case systemRoutable = "SYSTEM_ROUTABLE"
        case unreadMessages = "GET_UNREAD_MESSAGES_COUNT"
    }

    public enum DecodingError: Error {
        case noMessageData
    }

    public let chatRoomIdentifier: String?
    public let type: MessageType
    public let payload: [MessagingIncomingChatMetadata]

    private enum CodingKeys: String, CodingKey {
        case chatRoomIdentifier = "chat_room_identifier"
        case exception = "exception"
        case message = "message"
        case payload = "payload"
        case type = "type"
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        self.chatRoomIdentifier = try? keyedContainer.decodeValue(forKey: .chatRoomIdentifier)
        self.type = try keyedContainer.decodeValue(forKey: .type)

        switch self.type {
        case .error:
            if let message = try? keyedContainer.decode(MessagingChatErrorMessage.self, forKey: .exception) {
                self.payload = [message]
            } else {
                throw DecodingError.noMessageData
            }
        case .history, .messageRead, .messagesRead, .routable:
            if let messages = try? keyedContainer.decode([MessagingChatMessage].self, forKey: .payload) {
                self.payload = messages
            } else if let singleValueContainer = try? decoder.singleValueContainer(),
                      let message = try? singleValueContainer.decode(MessagingChatMessage.self) {
                self.payload = [message]
            } else {
                throw DecodingError.noMessageData
            }
        case .lastMessage:
            if let messages = try? keyedContainer.decode([MessagingChatMostRecentMessage].self, forKey: .payload) {
                self.payload = messages
            } else {
                throw DecodingError.noMessageData
            }
        case .systemRoutable:
            if let singleValueContainer = try? decoder.singleValueContainer(),
               let message = try? singleValueContainer.decode(MessagingChatSystemMessage.self) {
                self.payload = [message]
            } else {
                throw DecodingError.noMessageData
            }
        case .unreadMessages:
            if let messages = try? keyedContainer.decode([MessagingChatUnreadCountMessage].self, forKey: .payload) {
                self.payload = messages
            } else {
                throw DecodingError.noMessageData
            }
        }
    }
}

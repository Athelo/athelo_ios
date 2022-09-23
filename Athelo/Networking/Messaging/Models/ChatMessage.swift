//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatMessage: Decodable, Hashable {
    private static let unknownSender: String = "--sender.unknown"
    
    public let chatRoomIdentifier: String
    public let isSystemMessage: Bool
    public let timestamp: Int64
    public let userIdentifier: String
    public let message: String?
    public let userData: MessagingChatMessageUserData?

    var userIdentifierSansSuffix: String {
        userIdentifier.sansApplicationCodeSuffix()
    }

    private enum CodingKeys: String, CodingKey {
        case chatRoomIdentifier = "chat_room_identifier"
        case isSystemMessage = "is_system_message"
        case timestamp = "message_timestamp_identifier"
        case userIdentifier = "app_user_identifier"
        case message = "message"
        case userData = "custom_data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
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
            self.message = try container.decodeValueIfPresent(forKey: .message)

            self.isSystemMessage = try container.decodeValueIfPresent(forKey: .isSystemMessage) ?? false
            if self.isSystemMessage {
                self.userIdentifier = MessagingChatMessage.unknownSender
            } else {
                self.userIdentifier = try container.decodeValue(forKey: .userIdentifier)
            }

            if let customDataString: String = try container.decodeValueIfPresent(forKey: .userData),
               let customData = customDataString.data(using: .utf8),
               let userData = try? JSONDecoder().decode(MessagingChatMessageUserData.self, from: customData) {
                self.userData = userData
            } else {
                self.userData = nil
            }
        } catch let error {
            debugPrint(#fileID, #function, error)
            
            throw error
        }
    }
    
    public init(from systemMessage: MessagingChatSystemMessage) {
        self.chatRoomIdentifier = systemMessage.roomIdentifier
        self.message = systemMessage.message
        self.isSystemMessage = true
        self.timestamp = systemMessage.timestamp
        self.userData = nil
        self.userIdentifier = MessagingChatMessage.unknownSender
    }
}

extension MessagingChatMessage: MessagingIncomingChatMessageIdentifiableMetadata {
    public var incomingChatRoomID: String {
        chatRoomIdentifier
    }

    public var incomingChatMessageID: Int64 {
        timestamp
    }

    public var incomingChatMessageText: String? {
        message
    }
}

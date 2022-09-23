//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatUnreadCountMessage: Decodable, Hashable {
    public let chatRoomIdentifier: String
    public let unreadMessagesCount: Int

    private enum CodingKeys: String, CodingKey {
        case chatRoomIdentifier = "chat_room_identifier"
        case unreadMessagesCount = "unread_messages_count"
    }
}

extension MessagingChatUnreadCountMessage: MessagingIncomingChatRoomIdentifiableMetadata {
    public var incomingChatRoomID: String {
        chatRoomIdentifier
    }
}

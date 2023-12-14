//
//  ConversationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import Foundation

struct ConversationData: Hashable, Identifiable {
    let chatRoomIdentifier: String?
    let memberData: ChatRoomMemberData
    let recentMessage: MessagingChatMessage?
    let unreadCountMessage: MessagingChatUnreadCountMessage?
    
    var id: Int {
        memberData.id
    }
}

extension ConversationData {
    var avatarImage: LoadableImageData {
        memberData.avatarImage(in: .init(width: 48.0, height: 48.0))
    }
    
    var displayName: String {
        memberData.displayName ?? ""
    }
    
    var lastMessageDate: Date {
        recentMessage?.timestamp.asDateFrom1970(with: .nanoseconds) ?? Date(timeIntervalSince1970: 0)
    }
    
    var lastMessageText: String {
        recentMessage?.message ?? "conversation.list.nomessages".localized()
    }
    
    var unreadMessagesCount: Int {
        unreadCountMessage?.unreadMessagesCount ?? 0
    }
}

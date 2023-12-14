//
//  ConversationListView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import SwiftUI

struct ConversationListView: View {
    @ObservedObject private(set) var model: ConversationListModel
    let onSelectedItem: (ConversationData) -> Void
    
    var body: some View {
        FadingScrollView {
            ForEach(model.conversations) { conversation in
                ConversationItemView(messageData: conversation)
                    .onTapGesture {
                        onSelectedItem(conversation)
                    }
            }
            .transition(.slide.combined(with: .opacity))
            .animation(.default, value: model.conversations)
        }
    }
}

struct ConversationListView_Previews: PreviewProvider {
    static let model = ConversationListModel(conversations: [])
    
    static var previews: some View {
        VStack {
            ConversationListView(model: model, onSelectedItem: { _ in /* ... */ })
                .environmentObject(model)
        }
    }
    
    static func updateConversation(_ conversation: ConversationData, withUnreadMessageCount count: Int, messageText text: String) -> ConversationData {
        ConversationData(
            chatRoomIdentifier: conversation.chatRoomIdentifier,
            memberData: conversation.memberData,
            recentMessage: nil,
            unreadCountMessage: .from(
                chatRoomIdentifier: conversation.chatRoomIdentifier ?? "",
                count: count
            )
        )
    }
}

private extension ConversationData {
    static func from(chatRoomIdentifier: String, unreadCount: Int, text: String, date: Date) -> ConversationData {
        ConversationData(
            chatRoomIdentifier: chatRoomIdentifier,
            memberData: .init(id: 1, displayName: "Amina Harris", photo: nil),
            recentMessage: nil,
            unreadCountMessage: .from(chatRoomIdentifier: chatRoomIdentifier, count: unreadCount)
        )
    }
}

private extension MessagingChatMostRecentMessage {
    static func from(chatRoomIdentifier: String, hasUnreads: Bool, text: String, date: Date) -> MessagingChatMostRecentMessage {
        let data: [String: AnyHashable] = [
            "chat_room_identifier": chatRoomIdentifier,
            "has_unread_messages": hasUnreads,
            "last_message_text": text,
            "message_timestamp_identifier": Int64(date.timeIntervalSince1970 * 1_000_000)
        ]
        
        return try! JSONDecoder().decode(MessagingChatMostRecentMessage.self, from: try! JSONSerialization.data(withJSONObject: data))
    }
}

private extension MessagingChatUnreadCountMessage {
    static func from(chatRoomIdentifier: String, count: Int) -> MessagingChatUnreadCountMessage {
        let data: [String: AnyHashable] = [
            "chat_room_identifier": chatRoomIdentifier,
            "unread_messages_count": count
        ]
        
        return try! JSONDecoder().decode(MessagingChatUnreadCountMessage.self, from: try! JSONSerialization.data(withJSONObject: data))
    }
}

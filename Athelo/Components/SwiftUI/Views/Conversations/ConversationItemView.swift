//
//  ConversationItemView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import SwiftUI

struct ConversationItemView: View {
    let messageData: ConversationData
    
    private var messageDate: Date {
        messageData.lastMessageDate
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            HStack(alignment: .center, spacing: 8.0) {
                StyledImageView(
                    imageData: messageData.avatarImage,
                    contentMode: .scaleAspectFit
                )
                .frame(width: 48.0, height: 48.0)
                .roundedCorners(radius: 24.0)
                
                VStack(spacing: 8.0) {
                    HStack {
                        StyledText(
                            messageData.displayName,
                            textStyle: .textField,
                            colorStyle: .black,
                            alignment: .leading
                        )
                        .lineLimit(1)
                        
                        Spacer()
                        
                        if messageData.recentMessage != nil, messageData.unreadMessagesCount == 0 {
                            Image("checkmark")
                        }
                        
                        if messageDate.timeIntervalSince1970 > 0 {
                            StyledText(
                                messageDate.toRecentMessageDateDescription(),
                                textStyle: .subtitle,
                                colorStyle: .lightGray,
                                extending: false,
                                alignment: .trailing
                            )
                        }
                    }
                    .frame(minHeight: 24.0, alignment: .center)
                    
                    HStack(alignment: .center, spacing: 8.0) {
                        StyledText(
                            messageData.lastMessageText,
                            textStyle: .body,
                            colorStyle: .gray,
                            alignment: .leading
                        )
                        .lineLimit(1)
                        
                        if messageData.unreadMessagesCount > 0 {
                            StyledText(
                                "\(messageData.unreadMessagesCount)",
                                textStyle: .subtitle,
                                colorStyle: .white,
                                extending: false,
                                alignment: .center
                            )
                            .lineLimit(1)
                            .padding(4.0)
                            .frame(minWidth: 24.0, minHeight: 24.0, alignment: .center)
                            .background(
                                Rectangle()
                                    .fill(Color(UIColor.withStyle(.redFF0000).cgColor))
                                    .roundedCorners(radius: 12.0)
                            )
                        }
                    }
                    .frame(minHeight: 24.0, alignment: .center)
                }
            }
            .padding(.vertical, 16.0)
            .background(
                Rectangle()
                    .fill(Color(UIColor.withStyle(.background).cgColor))
            )
            
            Divider()
        }
        .padding(.horizontal, 16.0)
    }
}

struct ConversationItemView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationItemView(messageData: .from(chatRoomIdentifier: "chat_room_identifier", unreadCount: 0, text: ":)", date: Date()))
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

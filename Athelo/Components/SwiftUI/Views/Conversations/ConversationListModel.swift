//
//  ConversationListModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import Foundation

final class ConversationListModel: ObservableObject {
    @Published private(set) var conversations: [ConversationData]
    
    init(conversations: [ConversationData]) {
        self.conversations = conversations
    }
    
    func updateConversations(_ conversations: [ConversationData]) {
        self.conversations = conversations
    }
}

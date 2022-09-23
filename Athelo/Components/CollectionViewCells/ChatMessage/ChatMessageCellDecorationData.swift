//
//  ChatMessageCellDecorationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Foundation

struct ChatMessageCellDecorationData {
    let message: MessagingChatMessage
    let displaysAvatar: Bool
    let displaysDate: Bool
    let displaysOwnMessage: Bool
    let displaysSenderName: Bool
    
    init(message: MessagingChatMessage, displaysAvatar: Bool = false, displaysDate: Bool = false, displaysOwnMessage: Bool = false, displaysSenderName: Bool = false) {
        self.message = message
        self.displaysAvatar = displaysAvatar
        self.displaysDate = displaysDate
        self.displaysOwnMessage = displaysOwnMessage
        self.displaysSenderName = displaysSenderName
    }
}

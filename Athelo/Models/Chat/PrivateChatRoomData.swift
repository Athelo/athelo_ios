//
//  PrivateChatRoomData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/09/2022.
//

import Foundation

struct PrivateChatRoomData: Decodable, Hashable, Identifiable {
    let id: Int
    
    let chatRoomIdentifier: String
    let userProfile: ChatRoomMemberData
    
    private enum CodingKeys: String, CodingKey {
        case id
        
        case chatRoomIdentifier = "chat_room_identifier"
        case userProfile = "user_profile"
    }
}

extension PrivateChatRoomData: CommunityChatData {
    var belongTo: Bool {
        true
    }
    
    var chatRoomID: Int {
        id
    }
    
    var displayName: String? {
        userProfile.displayName ?? ""
    }
    
    var memberCount: Int? {
        nil
    }
}

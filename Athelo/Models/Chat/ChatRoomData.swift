//
//  ChatRoomData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Foundation

struct ChatRoomData: Decodable, Identifiable {
    let id: Int
    
    let belongTo: Bool
    let chatRoomIdentifierInt: Int
    let chatRoomType: Int
    let isPublic: Bool
    let name: String
    let userProfiles: [ChatRoomMemberData]
    let userProfilesCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case belongTo = "belong_to"
        case chatRoomIdentifierInt = "chat_room_identifier"
        case chatRoomType = "chat_room_type"
        case isPublic = "is_public"
        case userProfiles = "user_profiles"
        case userProfilesCount = "user_profiles_count"
    }
}

extension ChatRoomData: ChatRoomCellConfigurationData {
    var chatRoomID: Int {
        id
    }
    
    var chatRoomIsMember: Bool {
        belongTo
    }
    
    var chatRoomMembers: [ChatRoomMemberData]? {
        userProfiles
    }
    
    var chatRoomName: String {
        name
    }
    
    var chatRoomParticipantCount: Int {
        userProfilesCount
    }
}

extension ChatRoomData: CommunityChatData {
    var chatRoomIdentifier: String {
        String(chatRoomIdentifierInt)
    }
    
    var displayName: String? {
        name
    }
    
    var memberCount: Int? {
        userProfilesCount
    }
}

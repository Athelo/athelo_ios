//
//  CreatedChatData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/09/2022.
//

import Foundation

struct CreatedChatData: Decodable {
    let chatRoomIdentifier: String
    let userProfileID: Int
    
    private enum CodingKeys: String, CodingKey {
        case chatRoomIdentifier = "chat_room_identifier"
        case userProfileID = "user_profile_id"
    }
}

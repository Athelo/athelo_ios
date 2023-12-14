//
//  ChatRoomMemberData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Foundation

struct ChatRoomMemberData: Decodable, Hashable, Identifiable {
    let id: Int
    
    let displayName: String?
    let photo: ImageData?
    
    private enum CodingKeys: String, CodingKey {
        case id, photo
        case displayName = "display_name"
    }
}

extension ChatRoomMemberData: RendererAvatarSource {
    var rendererAvatarDisplayName: String? {
        displayName
    }
}

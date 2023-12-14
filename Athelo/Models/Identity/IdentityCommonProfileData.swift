//
//  IdentityShortProfileData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/02/2023.
//

import Foundation

struct IdentityCommonProfileData: Codable, Hashable, Identifiable {
    let id: Int
    
    let displayName: String?
    let photo: ImageData?
    let profileFriendVisibilityOnly: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, photo
        case displayName = "display_name"
        case profileFriendVisibilityOnly = "profile_friend_visbility_only"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.displayName = try? container.decodeValueIfPresent(forKey: .displayName)
        self.photo = try? container.decodeValueIfPresent(forKey: .photo)
        self.profileFriendVisibilityOnly = try? container.decodeValueIfPresent(forKey: .profileFriendVisibilityOnly)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(photo, forKey: .photo)
        try container.encodeIfPresent(profileFriendVisibilityOnly, forKey: .profileFriendVisibilityOnly)
    }
}

extension IdentityCommonProfileData: ContactData {
    var contactDisplayName: String? {
        displayName
    }
    
    var contactID: Int {
        id
    }
    
    var contactPhoto: ImageData? {
        photo
    }
    
    var contactRelationName: String? {
        nil
    }
}

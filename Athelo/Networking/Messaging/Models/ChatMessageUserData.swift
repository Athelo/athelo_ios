//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

public struct MessagingChatMessageUserData: Decodable, Hashable {
    public let displayName: String?
    public let firstName: String?
    public let lastName: String?
    public let photo: NetworkingImageData?
    public let userProfileID: Int?

    private enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case photo = "photo"
        case userProfileID = "user_profile_id"
    }
}


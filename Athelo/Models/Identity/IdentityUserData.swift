//
//  IdentityUserData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

struct IdentityUserData: Codable, Identifiable {
    let id: Int
    
    let i2aIdentifier: String
    let i2aUsername: String
    let username: String

    private enum CodingKeys: String, CodingKey {
        case id, username
        case i2aIdentifier = "i2a_identifier"
        case i2aUsername = "i2a_username"
    }
}

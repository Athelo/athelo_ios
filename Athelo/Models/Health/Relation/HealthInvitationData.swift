//
//  HealthInvitationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/03/2023.
//

import Foundation

struct HealthInvitationData: Identifiable, Decodable {
    let id: Int
    
    let code: String
    let email: String
    let expiresAt: Date
    let receiverNickName: String
    let relationLabel: String
    let status: String
    
    private enum CodingKeys: String, CodingKey {
        case id, email, status, code
        case expiresAt = "expires_at"
        case receiverNickName = "receiver_nick_name"
        case relationLabel = "relation_label"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.code = try container.decodeValue(forKey: .code)
        self.email = try container.decodeValue(forKey: .email)
        self.expiresAt = try container.decodeISODate(for: .expiresAt)
        self.receiverNickName = try container.decodeValue(forKey: .receiverNickName)
        self.relationLabel = try container.decodeValue(forKey: .relationLabel)
        self.status = try container.decodeValue(forKey: .status)
    }
    
}

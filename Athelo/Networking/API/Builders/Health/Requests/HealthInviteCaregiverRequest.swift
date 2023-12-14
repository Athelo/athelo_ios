//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Foundation

public struct HealthInviteCaregiverRequest: APIRequest {
    let caregiverNickName: String
    let email: String
    let relationLabel: String
    
    public init(caregiverNickName: String, email: String, relationLabel: String) {
        self.caregiverNickName = caregiverNickName
        self.email = email
        self.relationLabel = relationLabel
    }
    
    public var parameters: [String : Any]? {
        [
            "receiver_nick_name": caregiverNickName,
            "email": email,
            "relation_label": relationLabel
        ]
    }
}

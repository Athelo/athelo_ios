//
//  HealthRelationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/03/2023.
//

import Foundation

struct HealthRelationData: Decodable, Identifiable {
    let id: Int
    
    let caregiver: IdentityCommonProfileData?
    let patient: IdentityCommonProfileData?
    let permissions: IdentityCommonProfileData?
    let relationLabel: String
    
    private enum CodingKeys: String, CodingKey {
        case caregiver, id, patient, permissions
        case relationLabel = "relation_label"
    }
}

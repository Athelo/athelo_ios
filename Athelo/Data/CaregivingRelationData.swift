//
//  CaregivingRelationData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/09/2022.
//

import Foundation

struct CaregivingRelationData: Decodable, Identifiable {
    let id: Int
    let caregiver: IdentityProfileData
    let patient: IdentityProfileData
}

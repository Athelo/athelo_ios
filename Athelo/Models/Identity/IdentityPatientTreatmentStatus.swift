//
//  IdentityPatientProfile.swift
//  Athelo
//
//  Created by RD Singh on 2024-02-05.
//

import Foundation

struct IdentityPatientTreatmentStatus: Decodable, Identifiable {
    let active: Bool?
    let cancer_status: String?
    let id: Int?
}

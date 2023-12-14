//
//  UserRole.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/09/2022.
//

import Foundation

enum UserRole: Int, Hashable {
    case caregiver
    case patient
    
    var roleDescription: String {
        switch self {
        case .caregiver:
            return "role.caregiver".localized()
        case .patient:
            return "role.patient".localized()
        }
    }
}

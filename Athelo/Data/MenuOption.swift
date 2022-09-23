//
//  MenuOption.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation

enum MenuOption: String {
    case myProfile
    case messages
    case mySymptoms
    case myCaregivers
    case inviteACaregiver
    case settings
    case connectSmartWatch
    case askAthelo
    case sendFeedback
    
    var optionName: String {
        "menu.\(rawValue)".localized()
    }
}

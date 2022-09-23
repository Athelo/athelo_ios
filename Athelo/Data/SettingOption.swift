//
//  SettingOption.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Foundation

enum SettingOption {
    case aboutUs
    case notifications
    case personalInformation
    case privacyPolicy
    
    var title: String {
        switch self {
        case .aboutUs:
            return "settings.option.aboutus".localized()
        case .notifications:
            return "settings.option.notifications".localized()
        case .personalInformation:
            return "settings.option.personalinformation".localized()
        case .privacyPolicy:
            return "settings.option.privacypolicy".localized()
        }
    }
}

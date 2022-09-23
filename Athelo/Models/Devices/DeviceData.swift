//
//  DeviceData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation

enum DeviceType: Int, CaseIterable {
    case fitbit
    case appleWatch
    
    var name: String {
        switch self {
        case .appleWatch:
            return "device.name.applewatch".localized()
        case .fitbit:
            return "device.name.fitbit".localized()
        }
    }
    
    var shortName: String {
        switch self {
        case .appleWatch:
            return "device.shortname.applewatch".localized()
        case .fitbit:
            return "device.shortname.fitbit".localized()
        }
    }
}

struct DeviceData: Identifiable, Equatable {
    let type: DeviceType
    let connected: Bool
    
    var id: Int {
        type.rawValue
    }
    
    static func fromIdentityProfile(_ identityProfile: IdentityProfileData) -> [DeviceData] {
        var devices: [DeviceData] = []
        
        devices.append(.init(type: .fitbit, connected: identityProfile.hasFitbitUserProfile ?? false))
        devices.append(.init(type: .appleWatch, connected: false))
        
        return devices
    }
}

//
//  DeviceConfigData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/08/2022.
//

import Foundation

struct DeviceConfigData: Decodable {
    let applicationSettings: ApplicationSettingsData?
    let maxAppVersion: [Int]
    let minAppVersion: [Int]
    let type: String
    
    private enum CodingKeys: String, CodingKey {
        case type
        
        case applicationSettings = "application_settings"
        case maxAppVersion = "max_app_version"
        case minAppVersion = "min_app_version"
    }
}

//
//  ApplicationSettingsData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/08/2022.
//

import Foundation

struct ApplicationSettingsData: Decodable {
    let id: Int
    let details: ConfigurationDetailsData?
}

extension ApplicationSettingsData {
    struct ConfigurationDetailsData: Decodable {
        let sleepSettings: SleepConfigurationData?
        
        private enum CodingKeys: String, CodingKey {
            case sleepSettings = "sleep_settings"
        }
    }
    
    struct SleepConfigurationData: Decodable {
        let articleID: Int?
        let idealSleepSecs: Int?
        let idealSleepText: String?
        
        private enum CodingKeys: String, CodingKey {
            case articleID = "article_id"
            case idealSleepSecs = "ideal_sleep_secs"
            case idealSleepText = "ideal_sleep_text"
        }
        
        var isNotEmpty: Bool {
            articleID != nil || (idealSleepSecs ?? 0) > 0 || idealSleepText?.isEmpty == false
        }
    }
}

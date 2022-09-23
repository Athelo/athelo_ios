//
//  ActivityType.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

enum ActivityType: String {
    case exercise
    case heartRate = "heartrate"
    case hrv
    case steps
    
    var name: String {
        "activity.type.\(rawValue)".localized()
    }
}

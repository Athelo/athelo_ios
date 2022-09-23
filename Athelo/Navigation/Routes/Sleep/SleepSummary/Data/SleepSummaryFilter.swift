//
//  SleepSummaryFilter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

enum SleepSummaryFilter: String, CaseIterable, Equatable {
    case day
    case week
    case month
    
    var name: String {
        "sleep.summary.filter.\(rawValue)".localized()
    }
}

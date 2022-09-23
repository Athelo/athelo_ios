//
//  Date+ChatTimestamps.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 12/07/2022.
//

import Foundation
import SwiftDate

extension Date {
    var toChatTimestamp: Int64 {
        Int64(timeIntervalSince1970.asMeasurementUnit(UnitDuration.seconds).converted(to: .nanoseconds).value)
    }
    
    init(chatTimestamp: Int64) {
        let timeIntervalSince1970 = Double(chatTimestamp).asMeasurementUnit(UnitDuration.nanoseconds).converted(to: .seconds).value
        
        self.init(timeIntervalSince1970: timeIntervalSince1970)
    }
}

extension Int64 {
    func asDateFrom1970(with unit: UnitDuration, region: Region = .current) -> Date {
        let secondsSince1970 = Double(self).asMeasurementUnit(unit).converted(to: .seconds).value
        
        return DateInRegion(seconds: secondsSince1970, region: region).date
    }
}

//
//  SleepTimeData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

struct SleepTimeData: Equatable {
    let awakeTime: TimeInterval
    let deepSleepTime: TimeInterval
    let lightSleepTime: TimeInterval
    let remSleepTime: TimeInterval
    let date: Date?
    
    init(awakeTime: TimeInterval = 0.0, deepSleepTime: TimeInterval = 0.0, lightSleepTime: TimeInterval = 0.0, remSleepTime: TimeInterval = 0.0, date: Date? = nil) {
        self.awakeTime = max(0.0, awakeTime)
        self.deepSleepTime = max(0.0, deepSleepTime)
        self.lightSleepTime = max(0.0, lightSleepTime)
        self.remSleepTime = max(0.0, remSleepTime)
        self.date = date
    }
    
    init<C: Collection>(aggregates: C, date: Date? = nil) where C.Element == HealthSleepAggregatedPhaseRecord {
        self.awakeTime = aggregates[phase: .wake]?.duration ?? 0.0
        self.deepSleepTime = aggregates[phase: .deep]?.duration ?? 0.0
        self.lightSleepTime = aggregates[phase: .light]?.duration ?? 0.0
        self.remSleepTime = aggregates[phase: .rem]?.duration ?? 0.0
        self.date = date
    }
    
    var totalTime: TimeInterval {
        awakeTime + deepSleepTime + lightSleepTime + remSleepTime
    }
    
    var totalTimeSansAwakeStat: TimeInterval {
        deepSleepTime + lightSleepTime + remSleepTime
    }
}

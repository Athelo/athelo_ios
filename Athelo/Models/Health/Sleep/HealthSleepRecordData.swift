//
//  HealthSleepRecordData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

typealias SleepPhase = HealthSleepRecordData.SleepPhase

struct HealthSleepRecordData: Decodable {
    enum SleepPhase: String, CaseIterable, Decodable {
        case deep
        case light
        case rem
        case wake
        
        var name: String {
            "sleep.phase.\(rawValue)".localized()
        }
    }
    
    let collectedAtDate: Date
    let collectedAtTime: Date
    let duration: Double
    let level: SleepPhase
    
    var recordDate: Date {
        Date(timeIntervalSince1970: collectedAtDate.timeIntervalSince1970 + collectedAtTime.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400))
    }
    
    private enum CodingKeys: String, CodingKey {
        case duration, level
        
        case collectedAtDate = "collected_at_date"
        case collectedAtTime = "collected_at_time"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.collectedAtDate = try container.decodeDate(forKey: .collectedAtDate, format: "yyyy-MM-dd")
        self.collectedAtTime = try container.decodeDate(forKey: .collectedAtTime, format: "HH:mm:ss")
        self.duration = try container.decodeValue(forKey: .duration)
        self.level = try container.decodeValue(forKey: .level)
    }
}

//
//  HealthSleepAggregatedPhaseRecord.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

struct HealthSleepAggregatedPhaseRecord: Decodable {
    let date: Date
    let duration: TimeInterval
    let level: SleepPhase
    
    private enum CodingKeys: String, CodingKey {
        case date, duration, level
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try container.decodeDate(forKey: .date, format: "yyyy-MM-dd'T'HH:mm:ss")
        self.duration = try container.decodeValue(forKey: .duration)
        self.level = (try? container.decodeValue(forKey: .level)) ?? .wake
    }
}

extension Collection where Element == HealthSleepAggregatedPhaseRecord {
    subscript(phase sleepPhase: SleepPhase) -> HealthSleepAggregatedPhaseRecord? {
        first(where: { $0.level == sleepPhase })
    }
}

//
//  HealthSleepAggregatedRecord.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

struct HealthSleepAggregatedRecord: Decodable {
    let date: Date
    let duration: TimeInterval
    
    private enum CodingKeys: String, CodingKey {
        case date, duration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try container.decodeDate(forKey: .date, format: "yyyy-MM-dd'T'HH:mm:ss")
        self.duration = try container.decodeValue(forKey: .duration)
    }
}

//
//  HealthHRVDashboardData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import Foundation

struct HealthHRVDashboardData: Decodable, Hashable {
    let coverage: Double
    let date: Date
    let highFrequency: Double
    let lowFrequency: Double
    let rmssd: Double
    
    private enum CodingKeys: String, CodingKey {
        case coverage, date, rmssd
        
        case highFrequency = "high_frequency"
        case lowFrequency = "low_frequency"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.coverage = try container.decodeValue(forKey: .coverage)
        self.date = try container.decodeDate(forKey: .date, format: "yyyy-MM-dd'T'HH:mm:ss")
        self.highFrequency = try container.decodeValue(forKey: .highFrequency)
        self.lowFrequency = try container.decodeValue(forKey: .lowFrequency)
        self.rmssd = try container.decodeValue(forKey: .rmssd)
    }
    
    private init(date: Date, coverage: Double = 0.0, highFrequency: Double = 0.0, lowFrequency: Double = 0.0, rmssd: Double = 0.0) {
        self.coverage = coverage
        self.date = date
        self.highFrequency = highFrequency
        self.lowFrequency = lowFrequency
        self.rmssd = rmssd
    }
    
    static func empty(at date: Date) -> HealthHRVDashboardData {
        HealthHRVDashboardData(date: date)
    }
}

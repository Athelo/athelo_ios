//
//  HealthDashboardData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

struct HealthDashboardData: Decodable {
    let date: Date
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case date, value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try container.decodeDate(forKey: .date, format: "yyyy-MM-dd'T'HH:mm:ss")
        self.value = try container.decodeValue(forKey: .value)
    }
    
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

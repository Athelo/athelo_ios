//
//  HealthRecordData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/08/2022.
//

import Foundation

struct HealthRecordData: Decodable, Hashable {
    let collectedAtDate: Date
    let collectedAtTime: Date
    let value: Double
    
    private enum CodingKeys: String, CodingKey {
        case value
        
        case collectedAtDate = "collected_at_date"
        case collectedAtTime = "collected_at_time"
    }
    
    var recordDate: Date {
        Date(timeIntervalSince1970: collectedAtDate.timeIntervalSince1970 + collectedAtTime.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400))
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.collectedAtDate = try container.decodeDate(forKey: .collectedAtDate, format: "yyyy-MM-dd")
        self.collectedAtTime = try container.decodeDate(forKey: .collectedAtTime, format: "HH:mm:ss")
        self.value = try container.decodeValue(forKey: .value)
    }
}

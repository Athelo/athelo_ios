//
//  HealthSummaryData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 27/07/2022.
//

import Foundation

struct HealthSummaryData: Decodable {
    let feelings: [FeelingData]
    let occurrenceDate: Date
    let symptoms: [UserSymptomData]
    
    private enum CodingKeys: String, CodingKey {
        case feelings, symptoms
        
        case occurrenceDate = "occurrence_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.feelings = try container.decodeValue(forKey: .feelings)
        self.occurrenceDate = try container.decodeDate(forKey: .occurrenceDate, format: "yyyy-MM-dd")
        self.symptoms = try container.decodeValue(forKey: .symptoms)
    }
}

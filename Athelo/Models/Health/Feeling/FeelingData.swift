//
//  FeelingData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

struct FeelingData: Decodable, Identifiable {
    let id: Int
    
    let generalFeeling: Int
    let note: String?
    let occurrenceDate: Date
    
    var feeling: FeelingScale {
        FeelingScale(generalFeeling: generalFeeling)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, note
        
        case generalFeeling = "general_feeling"
        case occurrenceDate = "occurrence_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.generalFeeling = try container.decodeValue(forKey: .generalFeeling)
        self.note = try container.decodeValueIfPresent(forKey: .note)
        self.occurrenceDate = try container.decodeDate(forKey: .occurrenceDate, format: "yyyy-MM-dd")
    }
}

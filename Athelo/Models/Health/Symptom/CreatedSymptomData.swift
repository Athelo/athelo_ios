//
//  CreatedSymptomData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import Foundation

struct CreatedSymptomData: Decodable, Identifiable {
    let id: Int
    
    let occurrenceDate: Date
    let note: String?
    let symptomID: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, note
        
        case occurrenceDate = "occurrence_date"
        case symptomID = "symptom_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.occurrenceDate = try container.decodeDate(forKey: .occurrenceDate, format: "yyyy-MM-dd")
        self.note = try container.decodeValueIfPresent(forKey: .note)
        self.symptomID = try container.decodeValue(forKey: .symptomID)
    }
}

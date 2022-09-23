//
//  UserSymptomData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

struct UserSymptomData: Decodable, Identifiable {
    let id: Int
    
    let createdAt: Date
    let note: String?
    let occurrenceDate: Date
    let symptom: SymptomData
    let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, note, symptom
        
        case createdAt = "created_at"
        case occurrenceDate = "occurrence_date"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeValue(forKey: .id)
        
        self.createdAt = try container.decodeISODate(for: .createdAt)
        self.note = try container.decodeValueIfPresent(forKey: .note)
        self.occurrenceDate = try container.decodeDate(forKey: .occurrenceDate, format: "yyyy-MM-dd")
        self.symptom = try container.decodeValue(forKey: .symptom)
        self.updatedAt = try container.decodeISODate(for: .updatedAt)
    }
}

extension Array where Element == UserSymptomData {
    func uniqueByUnderlyingSymptomID() -> Array<UserSymptomData> {
        var uniqueItems: [UserSymptomData] = []
        
        for symptom in self {
            if !uniqueItems.contains(where: { $0.symptom.id == symptom.symptom.id }) {
                uniqueItems.append(symptom)
            }
        }
        
        return uniqueItems
    }
}

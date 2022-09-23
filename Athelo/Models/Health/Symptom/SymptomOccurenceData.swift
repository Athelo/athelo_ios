//
//  SymptomOccurenceData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Foundation

struct SymptomOccurrenceData: Decodable {
    let occurrencesCount: Int
    let symptom: SymptomData
    
    private enum CodingKeys: String, CodingKey {
        case symptom
        
        case occurrencesCount = "occurrences_count"
    }
}

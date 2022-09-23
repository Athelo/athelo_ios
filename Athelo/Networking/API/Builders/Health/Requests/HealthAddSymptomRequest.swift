//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

public struct HealthAddSymptomRequest: APIRequest {
    let note: String?
    let occurrenceDate: Date
    let symptomID: Int
    
    public init(symptomID: Int, occurrenceDate: Date, note: String? = nil) {
        self.symptomID = symptomID
        self.occurrenceDate = occurrenceDate
        self.note = note
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [
            "symptom_id": symptomID,
            "occurrence_date": occurrenceDate.toString(.custom("yyyy-MM-dd"))
        ]
        
        if let note = note, !note.isEmpty {
            params["note"] = note
        }
        
        return params
    }
}

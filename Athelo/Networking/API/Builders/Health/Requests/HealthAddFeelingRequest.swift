//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

public struct HealthAddFeelingRequest: APIRequest {
    let generalFeeling: Int
    let note: String?
    let occurrenceDate: Date
    
    public init(generalFeeling: Int, occurrenceDate: Date, note: String? = nil) {
        self.generalFeeling = generalFeeling
        self.occurrenceDate = occurrenceDate
        self.note = note
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [
            "general_feeling": generalFeeling,
            "occurrence_date": occurrenceDate.toString(.custom("yyyy-MM-dd"))
        ]
        
        if let note = note, !note.isEmpty {
            params["note"] = note
        }
        
        return params
    }
}

//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

public struct HealthUserSymptomsRequest: APIRequest {
    let occurrenceDates: [QueryDateData]?
    let symptomIDs: [Int]?
    
    public init(occurrenceDates: [QueryDateData]? = nil, symptomIDs: [Int]? = nil) {
        self.occurrenceDates = occurrenceDates
        self.symptomIDs = symptomIDs
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

public struct HealthSymptomsRequest: APIRequest {
    let query: String?
    let symptomIDs: [Int]?
    
    public init(query: String? = nil, symptomIDs: [Int]? = nil) {
        self.query = query
        self.symptomIDs = symptomIDs
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

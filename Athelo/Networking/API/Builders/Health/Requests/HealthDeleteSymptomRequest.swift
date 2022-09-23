//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import Foundation

public struct HealthDeleteSymptomRequest: APIRequest {
    let symptomID: Int
    
    public init(symptomID: Int) {
        self.symptomID = symptomID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

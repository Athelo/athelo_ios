//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import Foundation

public struct HealthRemovePatientRequest: APIRequest {
    let patientID: Int
    
    public init(patientID: Int) {
        self.patientID = patientID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

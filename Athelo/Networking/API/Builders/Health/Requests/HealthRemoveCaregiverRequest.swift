//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 23/03/2023.
//

import Foundation

public struct HealthRemoveCaregiverRequest: APIRequest {
    let caregiverID: Int
    
    public init(caregiverID: Int) {
        self.caregiverID = caregiverID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

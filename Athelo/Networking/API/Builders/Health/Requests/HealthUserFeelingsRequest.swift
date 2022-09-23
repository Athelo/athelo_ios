//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 14/07/2022.
//

import Foundation

public struct HealthUserFeelingsRequest: APIRequest {
    let occurrenceDates: [QueryDateData]?
    
    public init(occurrenceDates: [QueryDateData]? = nil) {
        self.occurrenceDates = occurrenceDates
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

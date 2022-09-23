//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 27/07/2022.
//

import Foundation

public struct HealthPerDaySummaryRequest: APIRequest {
    public enum Grouping {
        case byFeelings
        case bySymptoms
    }
    
    let grouping: Grouping?
    
    public init(grouping: Grouping? = nil) {
        self.grouping = grouping
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

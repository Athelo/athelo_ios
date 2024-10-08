//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

public struct HealthSleepRecordsRequest: APIRequest {
    let dates: [QueryDateData]?
    let exactMonth: Int?
    let exactYear: Int?
    
    public init(dates: [QueryDateData]? = nil, exactMonth: Int? = nil, exactYear: Int? = nil) {
        self.dates = dates
        self.exactMonth = exactMonth
        self.exactYear = exactYear
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 10/08/2022.
//

import Foundation

public struct HealthRecordsRequest: APIRequest {
    let dataType: HealthDashboardParameters.DataType
    let dates: [QueryDateData]?
    let pageSize: Int?
    
    public init(dataType: HealthDashboardParameters.DataType, dates: [QueryDateData]? = nil, pageSize: Int? = nil) {
        self.dataType = dataType
        self.dates = dates
        self.pageSize = pageSize
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

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
    let patientID: Int?
    
    public init(dataType: HealthDashboardParameters.DataType, dates: [QueryDateData]? = nil, pageSize: Int? = nil, patientID: Int?) {
        self.dataType = dataType
        self.dates = dates
        self.pageSize = pageSize
        self.patientID = patientID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

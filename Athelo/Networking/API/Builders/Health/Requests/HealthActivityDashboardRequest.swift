//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 16/08/2022.
//

import Foundation

public struct HealthActivityDashboardRequest: APIRequest {
    public typealias AggregationFunction = HealthDashboardParameters.AggregationFunction
    public typealias IntervalFunction = HealthDashboardParameters.IntervalFunction
    
    let aggregationFunction: AggregationFunction
    let endDate: Date
    let intervalFunction: IntervalFunction
    let startDate: Date
    let patientID: Int?
    
    public init(aggregationFunction: AggregationFunction, intervalFunction: IntervalFunction, startDate: Date, endDate: Date, patientID: Int? = nil) {
        self.aggregationFunction = aggregationFunction
        self.endDate = endDate
        self.intervalFunction = intervalFunction
        self.startDate = startDate
        self.patientID = patientID
    }
    
    public var parameters: [String : Any]? {
        [
            "aggregation_function": aggregationFunction.rawValue,
            "interval_function": intervalFunction.rawValue
        ]
    }
}

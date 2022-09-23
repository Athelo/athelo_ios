//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

public struct HealthDashboardRequest: APIRequest {
    public typealias AggregationFunction = HealthDashboardParameters.AggregationFunction
    public typealias DataType = HealthDashboardParameters.DataType
    public typealias IntervalFunction = HealthDashboardParameters.IntervalFunction
    
    let aggregationFunction: AggregationFunction
    let dataType: DataType
    let dates: [QueryDateData]?
    let intervalFunction: IntervalFunction
    
    public init(dataType: DataType, aggregationFunction: AggregationFunction, intervalFunction: IntervalFunction, dates: [QueryDateData]? = nil) {
        self.aggregationFunction = aggregationFunction
        self.dataType = dataType
        self.dates = dates
        self.intervalFunction = intervalFunction
    }
    
    public var parameters: [String : Any]? {
        [
            "aggregation_function": aggregationFunction.rawValue,
            "interval_function": intervalFunction.rawValue
        ]
    }
}

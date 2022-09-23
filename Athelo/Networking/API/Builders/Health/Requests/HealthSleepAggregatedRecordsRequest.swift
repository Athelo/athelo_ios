//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

public struct HealthSleepAggregatedRecordsRequest: APIRequest {
    public typealias AggregationFunction = HealthDashboardParameters.AggregationFunction
    public typealias IntervalFunction = HealthDashboardParameters.IntervalFunction
    
    public enum DataGranularity: CaseIterable {
        case all
        case byPhase
    }
    
    let aggregationFunction: AggregationFunction
    let dataGranularity: DataGranularity
    let dates: [QueryDateData]?
    let intervalFunction: IntervalFunction
    
    public init(granularity: DataGranularity, aggregationFunction: AggregationFunction, intervalFunction: IntervalFunction, dates: [QueryDateData]? = nil) {
        self.aggregationFunction = aggregationFunction
        self.dataGranularity = granularity
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

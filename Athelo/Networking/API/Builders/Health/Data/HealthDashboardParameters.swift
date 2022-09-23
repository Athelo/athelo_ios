//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

public enum HealthDashboardParameters {
    public enum AggregationFunction: String, CaseIterable {
        case avg = "AVG"
        case max = "MAX"
        case min = "MIN"
        case sum = "SUM"
    }
    
    public enum DataType: CaseIterable {
        case calories
        case heartRate
        case hrv
        case sleep
        case steps
    }
    
    public enum IntervalFunction: String, CaseIterable {
        case hour = "HOUR"
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
    }
}

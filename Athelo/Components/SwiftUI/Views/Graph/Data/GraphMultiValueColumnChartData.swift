//
//  GraphMultiValueColumnChartData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import Foundation

struct GraphMultiValueColumnChartData: Equatable, Hashable, Identifiable {
    let id: Int
    let values: [Double]
    
    let minValue: Double
    let maxValue: Double
    
    let label: String?
    let secondaryLabel: String?
    
    init(id: Int, values: [Double], minValue: Double, maxValue: Double, label: String? = nil, secondaryLabel: String? = nil) {
        self.id = id
        self.values = values
        
        self.minValue = minValue
        self.maxValue = maxValue
        
        self.label = label
        self.secondaryLabel = secondaryLabel
    }
}

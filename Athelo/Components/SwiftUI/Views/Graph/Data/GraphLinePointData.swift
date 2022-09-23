//
//  GraphLinePointData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import CoreGraphics
import Foundation

struct GraphLinePointData: Equatable, Hashable {
    let x: Double
    let y: Double
    
    let label: String?
    let secondaryLabel: String?
    
    init(x: Double, y: Double, label: String? = nil, secondaryLabel: String? = nil) {
        self.x = x
        self.y = y
        
        self.label = label
        self.secondaryLabel = secondaryLabel
    }
    
    var toPoint: CGPoint {
        .init(x: x, y: y)
    }
}

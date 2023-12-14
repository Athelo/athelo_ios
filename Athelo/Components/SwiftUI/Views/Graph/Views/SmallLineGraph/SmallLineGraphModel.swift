//
//  SmallLineGraphModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import Foundation
import SpriteKit

// NOTE: This is a workaround (rawValues property) for model update events (since graph is being drawn based on actual values). Published is being Published.
final class SmallLineGraphModel: ObservableObject {
    @Published private(set) var points: [GraphLinePointData]
    private(set) var rawValues: [GraphLinePointData]
    
    let interpolationMode: SKInterpolationMode
    
    init(points: [GraphLinePointData], interpolationMode: SKInterpolationMode) {
        self.interpolationMode = interpolationMode
        
        self.rawValues = points
        self.points = points
    }
    
    func updatePoints(_ points: [GraphLinePointData]) {
        self.rawValues = points
        self.points = points
    }
}

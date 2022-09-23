//
//  SmallLineGraphModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import Foundation
import SpriteKit

final class SmallLineGraphModel: ObservableObject {
    @Published private(set) var points: [GraphLinePointData]
    let interpolationMode: SKInterpolationMode
    
    init(points: [GraphLinePointData], interpolationMode: SKInterpolationMode) {
        self.interpolationMode = interpolationMode
        self.points = points
    }
    
    func updatePoints(_ points: [GraphLinePointData]) {
        self.points = points
    }
}

//
//  ActivitySummaryModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import CoreGraphics
import Foundation

final class ActivityTilesModel: ObservableObject {
    let activityGraphModel = SmallColumnGraphModel(items: [])
    let heartRateGraphModel = SmallColumnGraphModel(items: [])
    let hrvGraphModel = SmallLineGraphModel(points: [], interpolationMode: .spline)
    let stepsGraphModel = SmallColumnGraphModel(items: [])
    
    @Published private(set) var headerText: String?
    
    func updateActivityGraphItems(_ items: [GraphColumnItemData]) {
        activityGraphModel.updateItems(items)
    }
    
    func updateHeartRateGraphItems(_ items: [GraphColumnItemData]) {
        heartRateGraphModel.updateItems(items)
    }
    
    func updateHeaderText(_ text: String?) {
        headerText = text
    }
    
    func updateHRVGraphPoints(_ points: [GraphLinePointData]) {
        hrvGraphModel.updatePoints(points)
    }
    
    func updateStepsGraphItems(_ items: [GraphColumnItemData]) {
        stepsGraphModel.updateItems(items)
    }
}

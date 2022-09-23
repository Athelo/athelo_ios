//
//  LinearGraphModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/08/2022.
//

import Combine
import Foundation

struct LinearChartPointsData {
    let dataPoints: [GraphLinePointData]
    let customXMinValue: Double?
    let customXMaxValue: Double?
    
    init(dataPoints: [GraphLinePointData], customXMin: Double? = nil, customXMax: Double? = nil) {
        self.dataPoints = dataPoints
        self.customXMaxValue = customXMax
        self.customXMinValue = customXMin
    }
}

final class LinearChartModel: ObservableObject {
    @Published var columnCount: Int = 1
    @Published var displaysHorizontalGrid: Bool = false
    @Published var gridDrawingRule: GraphVerticalGridView.DrawingRule = .all
    @Published var legendWidth: Double = 30.0
    
    @Published private(set) var pointsData: LinearChartPointsData = .init(dataPoints: [])
    @Published private(set) var legendLabel: String?
    
    let horizontalItemsModel = GraphLegendItemsModel(legendItems: [])
    let verticalItemsModel = GraphLegendItemsModel(legendItems: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        sink()
    }
    
    // MARK: - Public API
    var adjustedMinXDataValue: Double {
        guard let minXValue = pointsData.dataPoints.minXValue() else {
            return 0.0
        }
        
        if let customXMinValue = pointsData.customXMinValue, customXMinValue < minXValue {
            return customXMinValue
        }
        
        return minXValue
    }
    
    var adjustedMinYDataValue: Double {
        pointsData.dataPoints.adjustedMinYValue()
    }
    
    var adjustedMaxXDataValue: Double {
        guard let maxXValue = pointsData.dataPoints.maxXValue() else {
            return 1.0
        }
        
        if let customXMaxValue = pointsData.customXMaxValue, customXMaxValue > maxXValue {
            return customXMaxValue
        }
        
        return maxXValue
    }
    
    var adjustedMaxYDataValue: Double {
        pointsData.dataPoints.adjustedMaxYValue()
    }
    
    func updateHorizontalColumnCount(_ columnCount: Int, gridDrawingRule: GraphVerticalGridView.DrawingRule) {
        self.columnCount = columnCount
        self.gridDrawingRule = gridDrawingRule
    }
    
    func updateHorizontalLegendItems(_ legendItems: [GraphLegendItemData]) {
        horizontalItemsModel.legendItems = legendItems
    }
    
    func updateLegendLabel(_ label: String?) {
        self.legendLabel = label
    }
    
    func updatePointsData(_ pointsData: LinearChartPointsData) {
        self.pointsData = pointsData
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        $pointsData
            .map({ LinearChartModel.legendItems(for: $0.dataPoints) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.verticalItemsModel.legendItems = $0
                self?.legendWidth = max(30.0, $0.maxContentWidth + 4.0)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func legendItems(for dataPoints: [GraphLinePointData]) -> [GraphLegendItemData] {
        var items: [GraphLegendItemData] = []
        
        let minY = dataPoints.adjustedMinYValue()
        let maxY = dataPoints.adjustedMaxYValue()
        
        let distance = maxY - minY
        let interval = distance.chartLegendInterval()
        
        var lastValue: Double = minY
        
        let stride = stride(from: minY, to: maxY, by: interval)
        for value in stride.enumerated() {
            items.append(.init(id: value.offset, name: "\(Int(value.element))"))
            lastValue = value.element
        }
        
        lastValue += interval
        items.append(.init(id: items.count, name: "\(Int(lastValue))"))
        
        return items
    }
}

private extension Array where Element == GraphLinePointData {
    func minXValue() -> Double? {
        map({ $0.x }).min()
    }
    
    func maxXValue() -> Double? {
        map({ $0.x }).max()
    }
    
    func adjustedMaxYValue() -> Double {
        var maxValue = Swift.max(1.0, map({ $0.y }).max() ?? 0.0)
        
        let legendDistance = maxValue.chartLegendInterval()
        maxValue = floor(maxValue)
        
        let difference = legendDistance - maxValue.truncatingRemainder(dividingBy: legendDistance)
        if difference < legendDistance {
            maxValue += difference
        }
        
        return maxValue
    }
    
    func adjustedMinYValue() -> Double {
        Swift.min(0.0, map({ $0.y }).min() ?? 0.0)
    }
}

//
//  GraphColumnChartData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Combine
import Foundation

struct GraphColumnChartData {
    let columns: [GraphColumnData]
    let customMaxValue: Double?
    let gridDrawingRule: GraphVerticalGridView.DrawingRule
    let horizontalLegendItems: [GraphLegendItemData]
    let legendLabel: String?
    
    init(columns: [GraphColumnData], horizontalLegendItems: [GraphLegendItemData], gridDrawingRule: GraphVerticalGridView.DrawingRule = .all, legendLabel: String? = nil, maxValue: Double? = nil) {
        self.columns = columns
        self.customMaxValue = maxValue
        self.gridDrawingRule = gridDrawingRule
        self.horizontalLegendItems = horizontalLegendItems
        self.legendLabel = legendLabel
    }
    
    fileprivate var adjustedMaxColumnValue: Double {
        var maxValue = columns.maxColumnValue
        if let customValue = customMaxValue, customValue > maxValue {
            maxValue = customValue
        }
        
        let legendDistance = maxValue.chartLegendInterval(looseningFirstIntervalGap: true)
        maxValue = floor(maxValue)
        
        let difference = legendDistance - maxValue.truncatingRemainder(dividingBy: legendDistance)
        if difference < legendDistance {
            maxValue += difference
        }
        
        return maxValue
    }
}

final class GraphColumnChartModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var data: GraphColumnChartData
    
    @Published var columnCount: Int = 1
    @Published var displaysHorizontalGrid: Bool = false
    @Published var gridDrawingRule: GraphVerticalGridView.DrawingRule = .all
    @Published var horizontalGridOffset: Double = 0.0
    @Published var legendWidth: Double = 30.0
    @Published var spacingGap: Double = 0.25
    
    var maxColumnValue: Double {
        data.adjustedMaxColumnValue
    }
    
    let horizontalItemsModel = GraphLegendItemsModel(legendItems: [])
    let verticalItemsModel = GraphLegendItemsModel(legendItems: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        self.data = GraphColumnChartData(columns: [], horizontalLegendItems: [])
        
        sink()
    }
    
    init(data: GraphColumnChartData) {
        self.data = data
        
        sink()
    }
    
    // MARK: - Public API
    func updateData(_ data: GraphColumnChartData) {
        self.data = data
    }
    
    func updateHorizontalGridOffset(_ gridOffset: Double) {
        guard gridOffset >= 0.0 else {
            return
        }
        
        self.horizontalGridOffset = gridOffset
    }
    
    func updateSpacingGap(_ spacingGap: Double) {
        let targetSpacingGap = max(0.0, min(1.0, spacingGap))
        
        self.spacingGap = targetSpacingGap
        horizontalItemsModel.spacingGap = targetSpacingGap
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        $data
            .sink { [weak self] in
                self?.horizontalItemsModel.legendItems = $0.horizontalLegendItems
                
                let verticalLegendItems = GraphColumnChartModel.legendItems(from: 0.0, to: $0.adjustedMaxColumnValue)
                self?.verticalItemsModel.legendItems = verticalLegendItems
                self?.legendWidth = max(30.0, verticalLegendItems.maxContentWidth + 4.0)
                
                self?.columnCount = $0.columns.count
                self?.gridDrawingRule = $0.gridDrawingRule
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func legendItems(from minValue: Double, to maxValue: Double) -> [GraphLegendItemData] {
        var items: [GraphLegendItemData] = []
        
        let distance = maxValue - minValue
        let interval = distance.chartLegendInterval(looseningFirstIntervalGap: true)
        
        var lastValue: Double = minValue
        
        let stride = stride(from: minValue, to: maxValue, by: interval)
        for value in stride.enumerated() {
            items.append(.init(id: value.offset, name: "\(Int(value.element))"))
            lastValue = value.element
        }
        
        lastValue += interval
        items.append(.init(id: items.count, name: "\(Int(lastValue))"))
        
        return items
    }
}

// MARK: - Helper extensions
private extension Array where Element == Int {
    func toLegendItems() -> [GraphLegendItemData] {
        enumerated().map({
            GraphLegendItemData(id: $0.offset, name: "\($0.element)")
        })
    }
}

private extension Array where Element == GraphColumnData {
    var minColumnValue: Double {
        ceil(map({ $0.items.map({ $0.value }).reduce(0.0, +) }).min() ?? 0.0)
    }
    
    var maxColumnValue: Double {
        ceil(map({ $0.items.map({ $0.value }).reduce(0.0, +) }).max() ?? 0.0) + 1.0
    }
}

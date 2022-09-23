//
//  MulrtiValueColumnChartModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/08/2022.
//

import Combine
import Foundation

final class MultiValueColumnChartModel: ObservableObject {
    @Published var columnCount: Int = 1
    @Published var displaysHorizontalGrid: Bool = false
    @Published var gridDrawingRule: GraphVerticalGridView.DrawingRule = .all
    @Published var gridHorizontalOffset: Double = 0.0
    @Published var legendWidth: Double = 30.0
    
    @Published private(set) var items: [GraphMultiValueColumnChartData]
    @Published private(set) var legendLabel: String?
    @Published var spacingGap: Double = 0.25
    
    let horizontalItemsModel = GraphLegendItemsModel(legendItems: [])
    let verticalItemsModel = GraphLegendItemsModel(legendItems: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(items: [GraphMultiValueColumnChartData]) {
        self.items = items
        
        sink()
    }
    
    // MARK: - Public API
    func updateItems(_ items: [GraphMultiValueColumnChartData]) {
        self.items = items
    }
    
    func updateHorizontalLegendItems(_ legendItems: [GraphLegendItemData]) {
        horizontalItemsModel.legendItems = legendItems
    }
    
    func updateHorizontalGridOffset(_ gridOffset: Double) {
        guard gridOffset >= 0.0 else {
            return
        }
        
        self.gridHorizontalOffset = gridOffset
    }
    
    func updateLegendLabel(_ legendLabel: String?) {
        self.legendLabel = legendLabel
    }
    
    func updateSpacingGap(_ spacingGap: Double) {
        let validSpacingGap = max(0.0, min(1.0, spacingGap))
        
        self.spacingGap = validSpacingGap
        horizontalItemsModel.spacingGap = validSpacingGap
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        $items
            .compactMap({ value -> (minY: Double, maxY: Double)? in
                guard let minY = value.map({ $0.minValue }).min(),
                      let maxY = value.map({ $0.maxValue }).max() else {
                    return nil
                }
                
                return (minY, maxY)
            })
            .map({ MultiValueColumnChartModel.legendItems(from: $0.minY, to: $0.maxY) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.verticalItemsModel.legendItems = $0
                self?.legendWidth = max(30.0, $0.maxContentWidth + 4.0)
            }.store(in: &cancellables)
        
        $items
            .map({ $0.count })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.columnCount = $0
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func legendItems(from minY: Double, to maxY: Double) -> [GraphLegendItemData] {
        var items: [GraphLegendItemData] = []
        
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

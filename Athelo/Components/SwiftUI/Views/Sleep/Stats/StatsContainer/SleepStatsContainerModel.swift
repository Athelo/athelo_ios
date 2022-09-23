//
//  SleepStatsContainerModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/08/2022.
//

import Combine
import Foundation

final class SleepStatsContainerModel: ObservableObject {
    // MARK: - Properties
    private static let dataUpdateQueue = DispatchQueue(label: "com.athelo.sleep.dataupdate", attributes: [.concurrent])
    
    @Published private(set) var avgTimeDescription: String = "---"
    @Published private(set) var filter: SleepSummaryFilter = .day
    
    @Published private(set) var dailySummaryData: SleepTimeData?
    @Published private(set) var weeklySummaryData: [SleepTimeData]?
    @Published private(set) var monthlySummaryData: [SleepTimeData]?
    
    private var sleepPercentageData: [SleepSummaryFilter: [SleepPhase: Double]] = [:]
    
    let weeklyGraphModel = GraphColumnChartModel(data: .init(columns: [], horizontalLegendItems: [], legendLabel: "graph.legend.sleep".localized()))
    let monthlyGraphModel = GraphColumnChartModel(data: .init(columns: [], horizontalLegendItems: [], gridDrawingRule: .monthGaps, legendLabel: "graph.legend.sleep".localized()))
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        monthlyGraphModel.spacingGap = 0.05
        
        sink()
    }
    
    // MARK: - Public API
    func assignDailySummaryData(_ data: SleepTimeData) {
        self.dailySummaryData = data
    }
    
    func assignFilter(_ filter: SleepSummaryFilter) {
        self.filter = filter
    }
    
    func assignMonthlySummaryData(_ data: [SleepTimeData]) {
        self.monthlySummaryData = data
    }
    
    func assignWeeklySummaryData(_ data: [SleepTimeData]) {
        self.weeklySummaryData = data
    }
    
    func percentage(for sleepPhase: SleepPhase) -> Int {
        guard sleepPhase != .wake,
              let data = sleepPercentageData[filter] else {
            return 0
        }
        
        return Int(round((data[sleepPhase] ?? 0.0) * 100.0))
    }
    
    var overviewHeader: String {
        "sleep.summary.overview.header.\(filter.rawValue)".localized()
    }
    
    var recommendation: String? {
        nil
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        $dailySummaryData
            .compactMap({ $0 })
            .map({ [$0].normalizedSleepTimes() })
            .sink { [weak self] in
                self?.sleepPercentageData[.day] = $0
            }.store(in: &cancellables)
        
        $weeklySummaryData
            .compactMap({ $0 })
            .map({ $0.normalizedSleepTimes() })
            .sink { [weak self] in
                self?.sleepPercentageData[.week] = $0
            }.store(in: &cancellables)
        
        $monthlySummaryData
            .compactMap({ $0 })
            .map({ $0.normalizedSleepTimes() })
            .sink { [weak self] in
                self?.sleepPercentageData[.month] = $0
            }.store(in: &cancellables)
        
        let dailySummaryDataUpdatePublisher = $filter
            .filter({ $0 == .day })
            .flatMap({ _ in self.$dailySummaryData })
        
        let weeklySummaryDataPublisher = $filter
            .filter({ $0 == .week })
            .flatMap({ _ in self.$weeklySummaryData })
        
        let monthlySummaryDataPublisher = $filter
            .filter({ $0 == .month })
            .flatMap({ _ in self.$monthlySummaryData })
        
        dailySummaryDataUpdatePublisher
            .map({ ($0?.totalTimeSansAwakeStat ?? 0.0).toSleepTimeString() })
            .sink { [weak self] in
                self?.avgTimeDescription = $0
            }.store(in: &cancellables)
        
        Publishers.Merge(
            weeklySummaryDataPublisher,
            monthlySummaryDataPublisher
        )
        .map({ $0?.filter({ $0.totalTimeSansAwakeStat > 0.0 }) })
        .map({ value -> String in
            guard let value = value, !value.isEmpty else {
                return 0.0.toSleepTimeString()
            }
            
            return (value.map({ $0.totalTimeSansAwakeStat }).reduce(0.0, +) / Double(value.count)).toSleepTimeString()
        })
        .sink { [weak self] in
            self?.avgTimeDescription = $0
        }.store(in: &cancellables)
        
        weeklySummaryDataPublisher
            .receive(on: Self.dataUpdateQueue)
            .map({ Self.prepareWeeklyGraphData(for: $0) })
            .debounce(for: 0.15, scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.weeklyGraphModel.updateData($0)
            }.store(in: &cancellables)
        
        monthlySummaryDataPublisher
            .receive(on: Self.dataUpdateQueue)
            .map({ Self.prepareMonthlyGraphData(for: $0) })
            .debounce(for: 0.15, scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.monthlyGraphModel.updateData($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func prepareMonthlyGraphData(for summaryData: [SleepTimeData]?) -> GraphColumnChartData {
        var columns: [GraphColumnData] = []
        var legendItems: [GraphLegendItemData] = []
        
        guard let data = summaryData, !data.isEmpty else {
            return GraphColumnChartData(columns: [], horizontalLegendItems: [], gridDrawingRule: .monthGaps, legendLabel: "graph.legend.sleep".localized())
        }
        
        for (idx, columnData) in data.enumerated() {
            let columnValue = columnData.remSleepTime + columnData.deepSleepTime + columnData.lightSleepTime
            let item = GraphColumnItemData(id: 0, color: .withStyle(.lightOlivaceous), value: columnValue / 3600.0, label: nil, labelColorStyle: .white)
            
            let label = columnValue.toSleepTimeString()
            
            var secondaryLabel: String?
            if let date = columnData.date {
                secondaryLabel = "- \(date.toFormat("dd MMM"))"
            }
            
            let column = GraphColumnData(id: columns.count, items: [item], label: label, secondaryLabel: secondaryLabel)
            
            var legendLabel = ""
            if idx == 0 || ((idx + 1) % 5 == 0) {
                legendLabel = "\(idx + 1)"
            }
            
            let legendItem = GraphLegendItemData(id: legendItems.count, name: legendLabel)
            
            columns.append(column)
            legendItems.append(legendItem)
        }
        
        return GraphColumnChartData(columns: columns, horizontalLegendItems: legendItems, gridDrawingRule: .monthGaps, legendLabel: "graph.legend.sleep".localized())
    }
    
    private static func prepareWeeklyGraphData(for summaryData: [SleepTimeData]?) -> GraphColumnChartData {
        var columns: [GraphColumnData] = []
        var legendItems: [GraphLegendItemData] = []
        
        guard let data = summaryData, !data.isEmpty else {
            return GraphColumnChartData(columns: [], horizontalLegendItems: [], legendLabel: "graph.legend.sleep".localized())
        }
        
        for columnData in data {
            var items: [GraphColumnItemData] = []
            if columnData.remSleepTime > 0.0 {
                items.append(.init(id: items.count, color: SleepPhase.rem.color, value: columnData.remSleepTime / 3600.0, label: Self.weekColumnValueDescription(for: columnData.remSleepTime), labelColorStyle: SleepPhase.rem.labelColorStyle))
            }
            if columnData.lightSleepTime > 0.0 {
                items.append(.init(id: items.count, color: SleepPhase.light.color, value: columnData.lightSleepTime / 3600.0, label: Self.weekColumnValueDescription(for: columnData.lightSleepTime), labelColorStyle: SleepPhase.light.labelColorStyle))
            }
            if columnData.deepSleepTime > 0.0 {
                items.append(.init(id: items.count, color: SleepPhase.deep.color, value: columnData.deepSleepTime / 3600.0, label: Self.weekColumnValueDescription(for: columnData.deepSleepTime), labelColorStyle: SleepPhase.deep.labelColorStyle))
            }
            
            let label = (columnData.remSleepTime + columnData.lightSleepTime + columnData.deepSleepTime).toSleepTimeString()
            
            var secondaryLabel: String?
            if let date = columnData.date {
                secondaryLabel = "- \(date.toFormat("dd MMM"))"
            }
            
            let column = GraphColumnData(id: columns.count, items: items, label: label, secondaryLabel: secondaryLabel)
            let legendItem = GraphLegendItemData(id: legendItems.count, name: columnData.date?.toFormat("EEEEEE") ?? "")
            
            columns.append(column)
            legendItems.append(legendItem)
        }
        
        return GraphColumnChartData(columns: columns, horizontalLegendItems: legendItems, legendLabel: "graph.legend.sleep".localized())
    }
    
    private static func weekColumnValueDescription(for value: TimeInterval) -> String? {
        guard value > 1800 else {
            return nil
        }
        
        return value.toSleepTimeString(unitsStyle: .positional)
    }
}

// MARK: - Helper extensions
private extension Array where Element == SleepTimeData {
    func normalizedSleepTimes(skippingAwakeTime: Bool = true) -> [SleepPhase: TimeInterval] {
        var deepSleepTime: TimeInterval = 0.0
        var lightSleepTime: TimeInterval = 0.0
        var remSleepTime: TimeInterval = 0.0
        var awakeSleepTime: TimeInterval = 0.0
        
        for item in self {
            deepSleepTime += item.deepSleepTime
            lightSleepTime += item.lightSleepTime
            remSleepTime += item.remSleepTime
            awakeSleepTime += item.awakeTime
        }
        
        var totalTime = deepSleepTime + lightSleepTime + remSleepTime
        if !skippingAwakeTime {
            totalTime += awakeSleepTime
        }
        
        guard totalTime > 0.0 else {
            return [.deep: 0.0, .light: 0.0, .rem: 0.0, .wake: 0.0]
        }
        
        var data: [SleepPhase: TimeInterval] = [
            .deep: deepSleepTime / totalTime,
            .light: lightSleepTime / totalTime,
            .rem: remSleepTime / totalTime
        ]
        
        if !skippingAwakeTime {
            data[.wake] = awakeSleepTime / totalTime
        }
        
        return data
    }
}

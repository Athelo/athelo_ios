//
//  ActivitySummaryModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import Combine
import Foundation

final class ActivitySummaryModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var activityType: ActivityType = .steps
    @Published private(set) var displayedGraph: DisplayedGraph = .column
    @Published private(set) var filter: ActivitySummaryFilter = .day
    @Published private(set) var overviewDescription: String = "---"
    
    let columnChartDataModel = GraphColumnChartModel(data: .init(columns: [], horizontalLegendItems: []))
    let linearChartDataModel = LinearChartModel()
    let multiValueColumnChartModel = MultiValueColumnChartModel(items: [])
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init(activityType: ActivityType) {
        self.activityType = activityType
        
        sink()
    }
    
    // MARK: - Public API
    func updateActivityType(_ activityType: ActivityType) {
        self.activityType = activityType
    }
    
    func updateOverviewDescription(_ description: String) {
        self.overviewDescription = description
    }
    
    func updateFilter(_ filter: ActivitySummaryFilter) {
        self.filter = filter
    }
    
    var infoText: String? {
        nil
    }
    
    var overviewHeader: String {
        "activity.summary.overview.header.\(filter.rawValue)".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoFilterSubjects()
    }
    
    private func sinkIntoFilterSubjects() {
        Publishers.CombineLatest(
            $activityType,
            $filter
        )
        .map({ (activity, filter) -> DisplayedGraph in
            switch activity {
            case .exercise, .steps:
                return .column
            case .heartRate:
                switch filter {
                case .day, .week:
                    return .multiValueColumn
                case .month:
                    return .linear
                }
            case .hrv:
                return .linear
            }
        })
        .removeDuplicates()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.displayedGraph = $0
        }.store(in: &cancellables)
    }
}

// MARK: Helper extensions
extension ActivitySummaryModel {
    enum DisplayedGraph {
        case column
        case linear
        case multiValueColumn
    }
}

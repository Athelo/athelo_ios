//
//  ActivitySummaryViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Combine
import SwiftDate
import Foundation

final class ActivitySummaryViewModel: BaseViewModel {
    // MARK: - Properties
    private let dataHandler = ActivitySummaryDataHandler()
    let dataModel = ActivitySummaryModel(activityType: .exercise)
    let wardModel = SelectedWardModel()
    
    private let chartDataCache = NSCache<RangeData.DataKey, CachedObjectWrapper>()
    
    @Published private(set) var canDisplayWardData: Bool = false
    @Published private(set) var canSelectNextRange: Bool = true
    @Published private(set) var rangeDescriptionHeader: String?
    @Published private(set) var rangeDescriptionBody: String?
    
    private let region: Region
    
    private let activeDayFilter: CurrentValueSubject<Date, Never>
    private let activeWeekFilter: CurrentValueSubject<WeekRangeData, Never>
    private let activeMonthFilter: CurrentValueSubject<Date, Never>
    
    private let roleUpdateSubject = CurrentValueSubject<Void, Never>(())
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override convenience init() {
        self.init(region: .UTC)
    }
    
    init(region: Region) {
        self.region = region
        
        let startOfDay = Date.timeZoneUnaware(in: region)
        
        self.activeDayFilter = CurrentValueSubject(startOfDay)
        self.activeWeekFilter = CurrentValueSubject(WeekRangeData(startingAt: startOfDay.dateAt(.startOfWeek).date))
        self.activeMonthFilter = CurrentValueSubject(startOfDay)
        
        super.init()
        
        guard let userRole = IdentityUtility.activeUserRole else {
            fatalError("Missing user role/context to display stat data.")
        }
        
        updateRoleData(userRole)
        
        sink()
    }
    
    // MARK: - Public API
    func selectNextRange() {
        guard canSelectNextRange else {
            return
        }
        
        switch dataModel.filter {
        case .day:
            activeDayFilter.send(activeDayFilter.value.dateByAdding(1, .day).date)
        case .week:
            activeWeekFilter.send(activeWeekFilter.value.futureRange())
        case .month:
            activeMonthFilter.send(activeMonthFilter.value.dateAt(.nextMonth).date)
        }
    }
    
    func selectPreviousRange() {
        switch dataModel.filter {
        case .day:
            activeDayFilter.send(activeDayFilter.value.dateByAdding(-1, .day).date)
        case .week:
            activeWeekFilter.send(activeWeekFilter.value.pastRange())
        case .month:
            activeMonthFilter.send(activeMonthFilter.value.dateAt(.prevMonth).date)
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.$activeRole
            .dropFirst()
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateRoleData($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        dataModel.$activityType
            .map({ $0.displaysHorizontalGridOnGraph })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dataModel.columnChartDataModel.displaysHorizontalGrid = $0
                self?.dataModel.linearChartDataModel.displaysHorizontalGrid = $0
                self?.dataModel.multiValueColumnChartModel.displaysHorizontalGrid = $0
            }.store(in: &cancellables)
        
        dataModel.$filter
            .map({ $0.graphSpacingGap })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dataModel.columnChartDataModel.updateSpacingGap($0)
                self?.dataModel.multiValueColumnChartModel.updateSpacingGap($0)
            }.store(in: &cancellables)
        
        let rangeDataPublisher: AnyPublisher<RangeData, Never> = Publishers.Merge3(
            dataModel.$filter
                .filter({ $0 == .day })
                .compactMap({ [weak self] _ in self?.activeDayFilter })
                .flatMap({ $0 })
                .map({ RangeData.day($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>,
            dataModel.$filter
                .filter({ $0 == .week })
                .compactMap({ [weak self] _ in self?.activeWeekFilter })
                .flatMap({ $0 })
                .map({ RangeData.week($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>,
            dataModel.$filter
                .filter({ $0 == .month })
                .compactMap({ [weak self] _ in self?.activeMonthFilter })
                .flatMap({ $0 })
                .map({ RangeData.month($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>
        ).eraseToAnyPublisher()
        
        rangeDataPublisher
            .compactMap({ [weak self] value -> String? in
                guard let region = self?.region else {
                    return nil
                }
                
                return ActivitySummaryViewModel.descriptionHeader(for: value, region: region)
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionHeader = $0
            }.store(in: &cancellables)
        
        rangeDataPublisher
            .map({ [weak self] value -> String? in
                guard let region = self?.region else {
                    return nil
                }
                
                return ActivitySummaryViewModel.descriptionBody(for: value, region: region)
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionBody = $0
            }.store(in: &cancellables)
        
        rangeDataPublisher
            .map({ [weak self] value -> Bool in
                guard let region = self?.region else {
                    return false
                }
                
                let referenceDate = Date.timeZoneUnaware(in: region)
                
                switch value {
                case .day(let date):
                    return date.compare(toDate: referenceDate, granularity: .day) == .orderedAscending
                case .week(let range):
                    return range.maxBound.compare(toDate: referenceDate, granularity: .day) == .orderedAscending
                case .month(let date):
                    return date.compare(toDate: referenceDate, granularity: .month) == .orderedAscending
                }
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.canSelectNextRange = $0
            }.store(in: &cancellables)
        
        Publishers.CombineLatest(
            rangeDataPublisher,
            roleUpdateSubject
        )
        .map({ $0.0 })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.handleDataUpdate(for: $0)
        }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func descriptionBody(for rangeData: RangeData, region: Region) -> String? {
        let referenceDate: Date = .timeZoneUnaware(in: region)
        
        switch rangeData {
        case .day(let date):
            let difference = date.difference(in: .day, from: referenceDate)
            switch difference {
            case .some(let days):
                switch days {
                case 0:
                    return "Today"
                case 1:
                    return "Yesterday"
                default:
                    return "\(days) days ago"
                }
            case .none:
                return nil
            }
        case .week(let range):
            let difference = range.minBound.difference(in: .day, from: referenceDate.dateAt(.startOfWeek).date)
            switch difference {
            case .some(let days):
                switch days {
                case _ where days < 7:
                    return "This week"
                case _ where days < 14:
                    return "Previous week"
                default:
                    return "\(days / 7) weeks ago"
                }
            case .none:
                return nil
            }
        case .month(let date):
            let difference = date.difference(in: .month, from: referenceDate)
            switch difference {
            case .some(let months):
                switch months {
                case 0:
                    return "This month"
                case 1:
                    return "Previous month"
                default:
                    return "\(months) months ago"
                }
            case .none:
                return nil
            }
        }
    }
    
    private static func descriptionHeader(for rangeData: RangeData, region: Region) -> String {
        switch rangeData {
        case .day(let date):
            return date.in(region: region).toFormat("MMMM dd, yyyy")
        case .week(let range):
            if range.minBound.year != range.maxBound.year {
                return "\(range.minBound.in(region: region).toFormat("MMMM dd, yyyy")) - \(range.maxBound.in(region: region).toFormat("MMMM dd, yyyy")))"
            } else if range.minBound.month != range.maxBound.month {
                return "\(range.minBound.in(region: region).toFormat("MMMM dd")) - \(range.maxBound.in(region: region).toFormat("MMMM dd, yyyy"))"
            } else {
                return "\(range.minBound.in(region: region).toFormat("MMMM dd")) - \(range.maxBound.in(region: region).toFormat("dd, yyyy"))"
            }
        case .month(let date):
            return date.in(region: region).toFormat("MMMM yyyy")
        }
    }
    
    private func handleDataUpdate(for rangeData: RangeData) {
        switch rangeData {
        case .day(let date):
            handleDailyDataUpdate(at: date)
        case .week(let weekRangeData):
            if dataModel.activityType == .heartRate {
                handleWeeklyHeartRateDataUpdate(at: weekRangeData)
            } else {
                handleWeeklyDataUpdate(at: weekRangeData)
            }
        case .month(let date):
            handleMonthlyDataUpdate(at: date)
        }
    }
    
    private func handleDailyDataUpdate(at date: Date) {
        let data = dataHandler.aggregateData(fromHour: date.dateAt(.startOfDay).date, to: date.dateAt(.endOfDay).dateAtStartOf(.hour).date)
        
        switch data {
        case .success(let dict):
            prepareGraphData(from: dict, inRange: .day(date), for: dataHandler.activeRole)
            prepareOverviewValueData(from: dict)
        case .failure(let date):
            guard state.value != .loading else {
                return
            }
            
            state.send(.loading)
            
            let requestUserRole = dataHandler.activeRole
            dataHandler.fetchHourlyAggregates(from: date, of: dataModel.activityType, step: ActivitySummaryDataHandler.Constants.dailyDataStep)
                .ignoreOutput()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    let result = $0.toViewModelState()
                    
                    if case .loaded = result {
                        self.handleDailyDataUpdate(at: date)
                    } else if case .error = result, requestUserRole.isCaregiver,
                              self.dataHandler.activeRole == requestUserRole,
                              !self.dataHandler.hasAnyData(for: requestUserRole) {
                        self.dataModel.displayEmptyData()
                    }
                    
                    self.state.send(result)
                }.store(in: &cancellables)
        }
    }
    
    private func handleWeeklyDataUpdate(at range: WeekRangeData) {
        let data = dataHandler.aggregateData(fromDay: range.minBound, to: range.maxBound)
        
        switch data {
        case .success(let dict):
            prepareGraphData(from: dict, inRange: .week(range), for: dataHandler.activeRole)
            prepareOverviewValueData(from: dict)
        case .failure(let date):
            guard state.value != .loading else {
                return
            }
            
            state.send(.loading)
            
            let requestUserRole = dataHandler.activeRole
            dataHandler.fetchDailyAggregates(from: date, of: dataModel.activityType, step: ActivitySummaryDataHandler.Constants.weeklyDataStep)
                .ignoreOutput()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    let result = $0.toViewModelState()
                    
                    if case .loaded = result {
                        self.handleWeeklyDataUpdate(at: range)
                    } else if case .error = result, requestUserRole.isCaregiver,
                              self.dataHandler.activeRole == requestUserRole,
                              !self.dataHandler.hasAnyData(for: requestUserRole) {
                        self.dataModel.displayEmptyData()
                    }
                    
                    self.state.send(result)
                }.store(in: &cancellables)
        }
    }
    
    private func handleWeeklyHeartRateDataUpdate(at range: WeekRangeData) {
        let data = dataHandler.heartRateWeeklyAggregateData(fromDay: range.minBound, to: range.maxBound)
        
        switch data {
        case .success(let dict):
            prepareGraphData(from: dict, inRange: .week(range), for: dataHandler.activeRole)
            prepareOverviewValueData(from: dict)
        case .failure(let date):
            guard state.value != .loading else {
                return
            }
            
            state.send(.loading)
            
            let requestUserRole = dataHandler.activeRole
            dataHandler.fetchHeartRateWeeklyAggregates(from: date, step: ActivitySummaryDataHandler.Constants.weeklyDataStep)
                .ignoreOutput()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    let result = $0.toViewModelState()
                    
                    if case .loaded = result {
                        self.handleWeeklyHeartRateDataUpdate(at: range)
                    } else if case .error = result, requestUserRole.isCaregiver,
                              self.dataHandler.activeRole == requestUserRole,
                              !self.dataHandler.hasAnyData(for: requestUserRole) {
                        self.dataModel.displayEmptyData()
                    }
                    
                    self.state.send(result)
                }.store(in: &cancellables)
        }
    }
    
    private func handleMonthlyDataUpdate(at date: Date) {
        let data = dataHandler.aggregateData(fromDay: date.dateAt(.startOfMonth).date, to: date.dateAt(.endOfMonth).dateAtStartOf(.day).date)
        
        switch data {
        case .success(let dict):
            prepareGraphData(from: dict, inRange: .month(date), for: dataHandler.activeRole)
            prepareOverviewValueData(from: dict)
        case .failure(let date):
            guard state.value != .loading else {
                return
            }
            
            state.send(.loading)
            
            let requestUserRole = dataHandler.activeRole
            dataHandler.fetchDailyAggregates(from: date, of: dataModel.activityType, step: ActivitySummaryDataHandler.Constants.monthlyDataStep)
                .ignoreOutput()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    let result = $0.toViewModelState()
                    
                    if case .loaded = result {
                        self.handleMonthlyDataUpdate(at: date)
                    } else if case .error = result, requestUserRole.isCaregiver,
                              self.dataHandler.activeRole == requestUserRole,
                              !self.dataHandler.hasAnyData(for: requestUserRole) {
                        self.dataModel.displayEmptyData()
                    }
                    
                    self.state.send(result)
                }.store(in: &cancellables)
        }
    }
    
    private func overviewAggregationRule() -> OverviewDataAggregationRule {
        switch dataModel.activityType {
        case .exercise, .steps:
            switch dataModel.filter {
            case .day:
                return .sum
            case .week, .month:
                return .average
            }
        case .heartRate:
            switch dataModel.filter {
            case .day, .week:
                return .minMax
            case .month:
                return .average
            }
        case .hrv:
            return .average
        }
    }
    
    private func prepareOverviewValueData(from dict: [Date: [ActivitySummaryDataHandler.SummaryDataPoint]]) {
        let unitData = dataModel.activityType.unitData
        
        switch overviewAggregationRule() {
        case .average:
            var totalValue: Double = 0.0
            var itemCount: Double = 0.0
            
            for values in dict.values {
                let nonZeroValues = values.filter({ $0.value > 0.0 })
                guard !nonZeroValues.isEmpty else {
                    continue
                }
                
                totalValue += nonZeroValues.map({ $0.value }).reduce(0.0, +)
                itemCount += Double(nonZeroValues.count)
            }
            
            let displayedValue = itemCount > 0 ? (totalValue / itemCount) : 0.0
            dataModel.updateOverviewDescription("\(Int(displayedValue)) \(unitData.unitName(for: displayedValue))")
        case .minMax:
            let validValues = dict.values.flatMap({ $0 }).map({ $0.value }).filter({ $0 > 0.0 }).sorted()
            if let minValue = validValues.first, let maxValue = validValues.last {
                if Int(minValue) != Int(maxValue) {
                    dataModel.updateOverviewDescription("\(Int(minValue)) - \(Int(maxValue)) \(unitData.plural)")
                } else {
                    dataModel.updateOverviewDescription("\(Int(minValue)) \(unitData.unitName(for: minValue))")
                }
            } else {
                dataModel.updateOverviewDescription("0 \(unitData.plural)")
            }
        case .sum:
            let displayedValue = dict.values.flatMap({ $0 }).map({ $0.value }).reduce(0.0, +)
            dataModel.updateOverviewDescription("\(Int(displayedValue)) \(unitData.unitName(for: displayedValue))")
        }
    }
    
    private func updateRoleData(_ userRole: ActiveUserRole) {
        dataHandler.changeActiveRole(userRole)
        roleUpdateSubject.send()
        
        switch userRole {
        case .caregiver(let patientData):
            canDisplayWardData = true
            wardModel.updateWard(patientData)
        case .patient:
            canDisplayWardData = false
            wardModel.updateWard(nil)
        }
    }
    
   // MARK: - Chart data handling
    private func prepareGraphData(from dict: [Date: [ActivitySummaryDataHandler.SummaryDataPoint]], inRange rangeData: RangeData, for userRole: ActiveUserRole) {
        let compositeCacheKey: NSString = NSString(format: "%@%@", [userRole.cacheKey, rangeData.dataKey])
        if let cachedData = chartDataCache.object(forKey: compositeCacheKey)?.wrapped as? CachedChartData {
            applyCachedChartData(cachedData)
            return
        }
        
        var columnEntries: [GraphColumnData] = []
        var linearEntries: [GraphLinePointData] = []
        var multiValueEntries: [GraphMultiValueColumnChartData] = []
        
        let allValues = dict.values.flatMap({ $0 }).map({ $0.value })
        let maxValue = allValues.max() ?? 0.0
        
        let sortedKeys = dict.keys.sorted(by: \.self)
        for dateKey in sortedKeys {
            guard let entries = dict[dateKey]?.sorted(by: \.date),
                  let firstEntry = entries.first else {
                continue
            }
            
            let unit = dataModel.activityType.unitData
            let label = valueDescriptionLabel(for: firstEntry.value, unit: unit)
            let secondaryLabel = "- \(valueDescriptionSecondaryLabel(for: firstEntry.date))"
            
            let columnItem = GraphColumnItemData(id: 0, color: .withStyle(.lightOlivaceous), value: firstEntry.value, label: "")
            let columnEntry = GraphColumnData(id: columnEntries.count, items: [columnItem], label: label, secondaryLabel: secondaryLabel)
            
            columnEntries.append(columnEntry)
            
            let multiValueLabel = multiValueLegendLabel(from: entries.map({ $0.value }), unit: unit)
            let multiValueGraphMaxValue = adjustedMaxValueForMultiValueChart(maxValue)
            let multiValueEntry = GraphMultiValueColumnChartData(id: multiValueEntries.count, values: entries.map({ $0.value }), minValue: 0.0, maxValue: multiValueGraphMaxValue, label: multiValueLabel, secondaryLabel: secondaryLabel)
            
            multiValueEntries.append(multiValueEntry)
            
            if firstEntry.value > 0.0 {
                let linearEntry = GraphLinePointData(x: dateKey.timeIntervalSince1970, y: firstEntry.value, label: label, secondaryLabel: secondaryLabel)
                
                linearEntries.append(linearEntry)
            }
        }
        
        var linearGraphXMin = 0.0
        var linearGraphXMax = 1.0
        
        if let firstDateKey = sortedKeys.first,
           let lastDateKey = sortedKeys.last {
            linearGraphXMin = firstDateKey.timeIntervalSince1970
            linearGraphXMax = lastDateKey.timeIntervalSince1970
        }
        
        let gridHorizontalOffset = dataModel.filter.gridHorizontalOffset
        let horizontalLegendEntries = horizontalLegendEntries(from: sortedKeys)
        let legendUnit = dataModel.activityType.unitData.short
        let gridDrawingRule = dataModel.filter.gridDrawingRule
        
        let chartData = CachedChartData(
            dates: sortedKeys,
            columnEntries: columnEntries,
            linearEntries: linearEntries,
            linearXMin: linearGraphXMin,
            linearXMax: linearGraphXMax,
            multiValueEntries: multiValueEntries,
            gridDrawingRule: gridDrawingRule,
            gridHorizontalOffset: gridHorizontalOffset,
            legendEntries: horizontalLegendEntries,
            legendUnit: legendUnit
        )
        
        applyCachedChartData(chartData)
        chartDataCache.setObject(.init(wrapped: chartData), forKey: rangeData.dataKey)
    }
    
    private func applyCachedChartData(_ data: CachedChartData) {
        dataModel.columnChartDataModel.updateData(
            .init(columns: data.columnEntries,
                  horizontalLegendItems: data.legendEntries,
                  gridDrawingRule: data.gridDrawingRule,
                  legendLabel: data.legendUnit)
        )
        dataModel.columnChartDataModel.updateHorizontalGridOffset(data.gridHorizontalOffset)
        
        dataModel.linearChartDataModel.updatePointsData(
            .init(dataPoints: data.linearEntries,
                  customXMin: data.linearXMin,
                  customXMax: data.linearXMax)
        )
        dataModel.linearChartDataModel.updateLegendLabel(data.legendUnit)
        dataModel.linearChartDataModel.updateHorizontalLegendItems(data.legendEntries)
        dataModel.linearChartDataModel.updateHorizontalColumnCount(data.dates.count, gridDrawingRule: data.gridDrawingRule)
        
        dataModel.multiValueColumnChartModel.updateItems(data.multiValueEntries)
        dataModel.multiValueColumnChartModel.updateLegendLabel(data.legendUnit)
        dataModel.multiValueColumnChartModel.updateHorizontalLegendItems(data.legendEntries)
        dataModel.multiValueColumnChartModel.updateHorizontalGridOffset(data.gridHorizontalOffset)
    }
    
    private func adjustedMaxValueForMultiValueChart(_ maxValue: Double) -> Double {
        var adjustedMaxValue = maxValue
        if adjustedMaxValue > 0.0 {
            let legendDistance = maxValue.chartLegendInterval()
            adjustedMaxValue = floor(adjustedMaxValue)
            
            let difference = legendDistance - adjustedMaxValue.truncatingRemainder(dividingBy: legendDistance)
            if difference < legendDistance {
                adjustedMaxValue += difference
            }
            
            if abs(adjustedMaxValue - maxValue) < legendDistance / 2.0 {
                let additionalDistance = (adjustedMaxValue + legendDistance).chartLegendInterval()
                adjustedMaxValue += additionalDistance
                
                let reminder = adjustedMaxValue.remainder(dividingBy: adjustedMaxValue.chartLegendInterval())
                adjustedMaxValue -= reminder
            }
        }
        
        adjustedMaxValue = max(1.0, adjustedMaxValue)
        
        return adjustedMaxValue
    }
    
    private func horizontalLegendEntries(from entries: [Date]) -> [GraphLegendItemData] {
        entries.enumerated().map({
            switch dataModel.filter {
            case .day:
                let legendLabel = ($0.offset % 4 == 0) ? legendLabel(for: $0.element) : ""
                return .init(id: $0.offset, name: legendLabel)
            case .week:
                return .init(id: $0.offset, name: legendLabel(for: $0.element))
            case .month:
                let shouldDisplayLegendLabel = $0.offset == 0 || (($0.offset + 1) % 5 == 0)
                let legendLabel = shouldDisplayLegendLabel ? legendLabel(for: $0.element) : ""
                
                return .init(id: $0.offset, name: legendLabel)
            }
        })
    }
    
    private func legendLabel(for date: Date) -> String {
        switch dataModel.filter {
        case .day:
            return date.toFormat("h a")
        case .week:
            return date.toFormat("EEEEEE")
        case .month:
            return date.toFormat("d")
        }
    }
    
    private func multiValueLegendLabel(from values: [Double], unit: UnitNameData) -> String {
        values.toRangeDescription(with: unit)
    }
    
    private func valueDescriptionLabel(for value: Double, unit: UnitNameData) -> String {
        switch dataModel.activityType {
        case .steps:
            return "\(Int(value)) \(unit.unitName(for: value))"
        case .exercise, .heartRate, .hrv:
            return "\(Int(value)) \(unit.short)"
        }
    }
    
    private func valueDescriptionSecondaryLabel(for date: Date) -> String {
        switch dataModel.filter {
        case .day:
            return date.toFormat("h:mm a")
        case .week:
            return date.toFormat("EEEE")
        case .month:
            return date.toFormat("d MMMM")
        }
    }
}

// MARK: - Helper extensions
private extension ActiveUserRole {
    var cacheKey: NSString {
        switch self {
        case .patient:
            return NSString(string: "patient:")
        case .caregiver(let patient):
            return NSString(string: "caregiver-\(patient.contactID):")
        }
    }
}

private extension ActivitySummaryViewModel {
    enum OverviewDataAggregationRule {
        case average
        case minMax
        case sum
    }
    
    enum RangeData {
        case day(Date)
        case week(WeekRangeData)
        case month(Date)
        
        typealias DataKey = NSString
        
        var dataKey: NSString {
            switch self {
            case .day(let date):
                return .init(string: "day-\(date.timeIntervalSince1970)")
            case .week(let range):
                return .init(string: "week-\(range.minBound.timeIntervalSince1970)")
            case .month(let date):
                return .init(string: "month-\(date.timeIntervalSince1970)")
            }
        }
    }
    
    struct CachedChartData {
        let dates: [Date]
        
        let columnEntries: [GraphColumnData]
        
        let linearEntries: [GraphLinePointData]
        let linearXMin: Double
        let linearXMax: Double
        
        let multiValueEntries: [GraphMultiValueColumnChartData]
        
        let gridDrawingRule: GraphVerticalGridView.DrawingRule
        let gridHorizontalOffset: Double
        let legendEntries: [GraphLegendItemData]
        let legendUnit: String
    }
    
    struct WeekRangeData {
        let minBound: Date
        let maxBound: Date
        
        init(endingAt date: Date) {
            self.minBound = date.dateByAdding(-6, .day).date
            self.maxBound = date
        }
        
        init(startingAt date: Date) {
            self.minBound = date
            self.maxBound = date.dateByAdding(6, .day).date
        }
        
        func futureRange() -> WeekRangeData {
            WeekRangeData(startingAt: maxBound.dateByAdding(1, .day).date)
        }
        
        func pastRange() -> WeekRangeData {
            WeekRangeData(endingAt: minBound.dateByAdding(-1, .day).date)
        }
    }
    
    final class CachedObjectWrapper: NSObject {
        let wrapped: Any
        
        init(wrapped: Any) {
            self.wrapped = wrapped
        }
    }
}

private extension ActivityType {
    var displaysHorizontalGridOnGraph: Bool {
        switch self {
        case .exercise, .heartRate, .steps:
            return true
        case .hrv:
            return false
        }
    }
    
    var unitData: UnitNameData {
        switch self {
        case .exercise:
            return UnitNameData(
                plural: "unit.minute.plural".localized(),
                short: "unit.minute.short".localized(),
                singular: "unit.minute.singular".localized()
            )
        case .heartRate:
            return UnitNameData(
                plural: "unit.heartbeat.plural".localized(),
                short: "unit.heartbeat.short".localized(),
                singular: "unit.heartbeat.singular".localized()
            )
        case .hrv:
            return UnitNameData(
                plural: "unit.milisecond.plural".localized(),
                short: "unit.milisecond.short".localized(),
                singular: "unit.milisecond.singular".localized()
            )
        case .steps:
            return UnitNameData(
                plural: "unit.step.plural".localized(),
                short: "unit.step.short".localized(),
                singular: "unit.step.singular".localized()
            )
        }
    }
}

private extension ActivitySummaryFilter {
    var gridDrawingRule: GraphVerticalGridView.DrawingRule {
        switch self {
        case .day:
            return .constant(4)
        case .week:
            return .all
        case .month:
            return .monthGaps
        }
    }
    
    var gridHorizontalOffset: Double {
        switch self {
        case .day, .week:
            return 8.0
        case .month:
            return 0.0
        }
    }
}

private extension ActivitySummaryFilter {
    var graphSpacingGap: Double {
        switch self {
        case .day:
            return 0.25
        case .month:
            return 0.05
        case .week:
            return 0.60
        }
    }
}

private extension Date {
    static func timeZoneUnaware(in region: Region) -> Date {
        Date().converted(to: region)
    }
    
    func converted(to region: Region) -> Date {
        guard let convertedDate = Date(self.in(region: .current).toFormat("yyyy/MM/dd"), format: "yyyy/MM/dd", region: region) else {
            fatalError("Could not convert \(self) to \(region).")
        }
        
        return convertedDate
    }
}

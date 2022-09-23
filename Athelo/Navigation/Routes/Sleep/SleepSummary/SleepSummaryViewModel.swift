//
//  SleepSummaryViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Combine
import SwiftDate
import UIKit

final class SleepSummaryViewModel: BaseViewModel {
    // MARK: - Properties
    private let dataHandler = SleepSummaryDataHandler()
    let dataModel = SleepStatsContainerModel()
    
    @Published private(set) var canSelectNextRange: Bool = true
    @Published private(set) var rangeDescriptionHeader: String?
    @Published private(set) var rangeDescriptionBody: String?
    
    private let activeDayFilter = CurrentValueSubject<Date, Never>(Date())
    private let activeWeekFilter = CurrentValueSubject<WeekRangeData, Never>(.init(startingAt: Date().dateAt(.startOfWeek).date))
    private let activeMonthFilter = CurrentValueSubject<Date, Never>(Date())
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
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
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let rangeDataPublisher: AnyPublisher<RangeData, Never> = Publishers.Merge3(
            dataModel.$filter
                .filter({ $0 == .day })
                .flatMap({ _ in self.activeDayFilter })
                .map({ RangeData.day($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>,
            dataModel.$filter
                .filter({ $0 == .week })
                .flatMap({ _ in self.activeWeekFilter })
                .map({ RangeData.week($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>,
            dataModel.$filter
                .filter({ $0 == .month })
                .flatMap({ _ in self.activeMonthFilter })
                .map({ RangeData.month($0) })
                .eraseToAnyPublisher() as AnyPublisher<RangeData, Never>
        ).eraseToAnyPublisher()
        
        rangeDataPublisher
            .map({ value -> String in
                switch value {
                case .day(let date):
                    return date.toFormat("MMMM dd, yyyy")
                case .week(let range):
                    if range.minBound.year != range.maxBound.year {
                        return "\(range.minBound.toFormat("MMMM dd, yyyy")) - \(range.maxBound.toFormat("MMMM dd, yyyy")))"
                    } else if range.minBound.month != range.maxBound.month {
                        return "\(range.minBound.toFormat("MMMM dd")) - \(range.maxBound.toFormat("MMMM dd, yyyy"))"
                    } else {
                        return "\(range.minBound.toFormat("MMMM dd")) - \(range.maxBound.toFormat("dd, yyyy"))"
                    }
                case .month(let date):
                    return date.toFormat("MMMM yyyy")
                }
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionHeader = $0
            }.store(in: &cancellables)
        
        rangeDataPublisher
            .map({ value -> Bool in
                switch value {
                case .day(let date):
                    return date.compare(toDate: Date(), granularity: .day) == .orderedAscending
                case .week(let range):
                    return range.maxBound.compare(toDate: Date(), granularity: .day) == .orderedAscending
                case .month(let date):
                    return date.compare(toDate: Date(), granularity: .month) == .orderedAscending
                }
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.canSelectNextRange = $0
            }.store(in: &cancellables)
        
        rangeDataPublisher
            .map({ value -> String? in
                switch value {
                case .day(let date):
                    let difference = date.difference(in: .day, from: Date())
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
                    let difference = range.minBound.difference(in: .day, from: Date().dateAt(.startOfWeek).date)
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
                    let difference = date.difference(in: .month, from: Date())
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
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionBody = $0
            }.store(in: &cancellables)
        
        rangeDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleDataUpdate(for: $0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func handleDataUpdate(for rangeData: RangeData) {
        switch rangeData {
        case .day(let date):
            if let data = dataHandler.phaseSumAggregateData(at: date) {
                dataModel.assignDailySummaryData(data)
            } else {
                guard state.value != .loading else {
                    return
                }
                
                state.value = .loading
                
                dataHandler.fetchPhaseSumAggregateData(from: date)
                    .ignoreOutput()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        let result = $0.toViewModelState()
                        
                        if case .loaded = result {
                            self?.handleDataUpdate(for: rangeData)
                        }
                        
                        self?.state.send(result)
                    }.store(in: &cancellables)
            }
        case .week:
            let currentRange = activeWeekFilter.value
            let result = dataHandler.phaseSumAggregateData(from: currentRange.minBound, to: currentRange.maxBound)
            
            switch result {
            case .success(let data):
                dataModel.assignWeeklySummaryData(data)
            case .failure(let date):
                guard state.value != .loading else {
                    return
                }
                
                state.value = .loading
                
                dataHandler.fetchPhaseSumAggregateData(from: date, step: SleepSummaryDataHandler.Constants.weeklyDataStep)
                    .ignoreOutput()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        let result = $0.toViewModelState()
                        
                        if case .loaded = result {
                            self?.handleDataUpdate(for: rangeData)
                        }
                        
                        self?.state.send(result)
                    }.store(in: &cancellables)
            }
        case .month:
            let currentDate = activeMonthFilter.value
            let result = dataHandler.phaseSumAggregateData(from: currentDate.dateAt(.startOfMonth).date, to: currentDate.dateAt(.endOfMonth).date)
            
            switch result {
            case .success(let data):
                dataModel.assignMonthlySummaryData(data)
            case .failure(let date):
                guard state.value != .loading else {
                    return
                }
                
                state.value = .loading
                
                dataHandler.fetchPhaseSumAggregateData(from: date, step: SleepSummaryDataHandler.Constants.monthlyDataStep)
                    .ignoreOutput()
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        let result = $0.toViewModelState()
                        
                        if case .loaded = result {
                            self?.handleDataUpdate(for: rangeData)
                        }
                        
                        self?.state.send(result)
                    }.store(in: &cancellables)
            }
        }
    }
}

// MARK: - Helper extensions
private extension SleepSummaryViewModel {
    enum RangeData {
        case day(Date)
        case week(WeekRangeData)
        case month(Date)
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
}

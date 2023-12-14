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
    let wardModel = SelectedWardModel()
    
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
                if $0.isCaregiver == true {
                    self?.dataModel.displayEmptyData()
                }
                
                self?.updateRoleData($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
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
                
                return SleepSummaryViewModel.descriptionHeader(for: value, region: region)
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionHeader = $0
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
        
        rangeDataPublisher
            .map({ [weak self] value -> String? in
                guard let region = self?.region else {
                    return nil
                }
                
                return SleepSummaryViewModel.descriptionBody(for: value, region: region)
            })
            .removeDuplicates()
            .sink { [weak self] in
                self?.rangeDescriptionBody = $0
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
        let referenceDate = Date.timeZoneUnaware(in: region)
        
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
        let requestUserRole = dataHandler.activeRole
        let requestHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] in
            guard let self else {
                return
            }
            
            let result = $0.toViewModelState()
            
            if case .loaded = result {
                self.handleDataUpdate(for: rangeData)
            } else if case .error = result, requestUserRole.isCaregiver,
                      self.dataHandler.activeRole == requestUserRole,
                      !self.dataHandler.hasAnyData(for: requestUserRole) {
                self.dataModel.displayEmptyData()
            }
            
            self.state.send(result)
        }
        
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
                    .sink(receiveCompletion: requestHandler)
                    .store(in: &cancellables)
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
                    .sink(receiveCompletion: requestHandler)
                    .store(in: &cancellables)
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
                    .sink(receiveCompletion: requestHandler)
                    .store(in: &cancellables)
            }
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
}

// MARK: - Helper extensions
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

//
//  SleepSummaryDataHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Combine
import Foundation
import SwiftDate

final class SleepSummaryDataHandler {
    // MARK: Constants
    enum Constants {
        static let dailyDataStep: Int = 30
        static let weeklyDataStep: Int = 70
        static let monthlyDataStep: Int = 200
    }
    
    private final class AggregateData {
        let userRole: ActiveUserRole
        
        init(userRole: ActiveUserRole) {
            self.userRole = userRole
        }
        
        var dailyPhaseSumAggregates: [Date: [HealthSleepAggregatedPhaseRecord]] = [:]
        
        var isEmpty: Bool {
            dailyPhaseSumAggregates.isEmpty
        }
    }
    
    // MARK: - Properties
    private var aggregateData: [ActiveUserRole: AggregateData] = [:]
    private(set) var activeRole: ActiveUserRole = .patient
    
    // MARK: - Public API
    func changeActiveRole(_ activeRole: ActiveUserRole) {
        self.activeRole = activeRole
    }
    
    func fetchPhaseSumAggregateData(from date: Date, step: Int = Constants.dailyDataStep) -> AnyPublisher<Void, Error> {
        let lowerBound = date.dateByAdding(-max(0, step), .day).date
        let upperBound = date
        
        let currentUserRole = activeRole
        let patientID = currentUserRole.relatedPatientID
        
        let dateRanges: [QueryDateData] = [.lowerBound(lowerBound, canBeEqual: true), .upperBound(upperBound.dateByAdding(2, .day).date, canBeEqual: true)]
        let request = HealthSleepAggregatedRecordsRequest(granularity: .byPhase, aggregationFunction: .sum, intervalFunction: .day, dates: dateRanges, patientID: patientID)
        
        return (AtheloAPI.Health.sleepAggregatedRecords(request: request) as AnyPublisher<[HealthSleepAggregatedPhaseRecord], APIError>)
            .handleEvents(receiveOutput: { [weak self] value in
                guard let self else {
                    return
                }
                
                let aggregateData = self.roleAggregateData(for: currentUserRole)
                
                let groupings = Dictionary(grouping: value.insertingDummyEntries(between: lowerBound, and: upperBound), by: \.date)
                for grouping in groupings {
                    aggregateData.dailyPhaseSumAggregates[day: grouping.key] = grouping.value
                }
            })
            .map({ _ in () })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    func hasAnyData(for userRole: ActiveUserRole) -> Bool {
        guard let data = aggregateData[userRole] else {
            return false
        }
        
        return !data.isEmpty
    }
    
    func phaseSumAggregateData(at date: Date) -> SleepTimeData? {
        guard let aggregates = aggregateData(for: activeRole, at: date) else {
            return nil
        }
        
        return SleepTimeData(aggregates: aggregates, date: date)
    }
    
    func phaseSumAggregateData(from lowerBound: Date, to upperBound: Date) -> AggregateDataResult {
        var items: [SleepTimeData] = []
        
        var referenceDate = upperBound
        while referenceDate.compare(toDate: lowerBound, granularity: .day) != .orderedAscending {
            guard let sleepTimeData = phaseSumAggregateData(at: referenceDate) else {
                return .failure(referenceDate)
            }
            
            items.insert(sleepTimeData, at: 0)
            
            referenceDate = referenceDate.dateByAdding(-1, .day).date
        }
        
        return .success(items)
    }
    
    // MARK: - Data access
    private func aggregateData(for userRole: ActiveUserRole, at date: Date) -> [HealthSleepAggregatedPhaseRecord]? {
        roleAggregateData(for: userRole).dailyPhaseSumAggregates[day: date]
    }
    
    private func roleAggregateData(for userRole: ActiveUserRole) -> AggregateData {
        if let existingAggregateData = aggregateData[userRole] {
            return existingAggregateData
        }
        
        let targetAggregateData = AggregateData(userRole: userRole)
        
        aggregateData[userRole] = targetAggregateData
        return targetAggregateData
    }
}

// MARK: - Helper extensions
extension SleepSummaryDataHandler {
    enum AggregateDataResult {
        /// Contains data for requested range.
        case success([SleepTimeData])
        /// Contains upper bound for which items were missing.
        case failure(Date)
    }
}

private extension Array where Element == HealthSleepAggregatedPhaseRecord {
    func insertingDummyEntries(between lowerBound: Date, and upperBound: Date) -> [HealthSleepAggregatedPhaseRecord] {
        var items = self
        var dates = Set(map({ $0.date }))
        
        var referenceDate = lowerBound
        while referenceDate.compare(toDate: upperBound, granularity: .day) != .orderedDescending {
            if let matchingDate = dates.first(where: { $0.compare(toDate: referenceDate, granularity: .day) == .orderedSame }) {
                dates.remove(matchingDate)
            } else {
                items.append(contentsOf: HealthSleepAggregatedPhaseRecord.dummyRecords(for: referenceDate))
            }
            
            referenceDate = referenceDate.date.dateByAdding(1, .day).date
        }
        
        return items
    }
}

private extension HealthSleepAggregatedPhaseRecord {
    static func dummyRecords(for date: Date) -> [HealthSleepAggregatedPhaseRecord] {
        SleepPhase.allCases.map({ .init(dummyLevel: $0, date: date) })
    }
    
    private init(dummyLevel: SleepPhase, date: Date) {
        self.date = date
        self.level = dummyLevel
        self.duration = 0.0
    }
}
                                
private extension Dictionary where Key == Date {
    subscript(day date: Date) -> Value? {
        get {
            return self[date.dateAt(.startOfDay).date]
        }
        set {
            self[date.dateAt(.startOfDay).date] = newValue
        }
    }
    
    subscript(month date: Date) -> Value? {
        get {
            return self[date.dateAt(.startOfMonth).date]
        }
        set {
            self[date.dateAt(.startOfMonth).date] = newValue
        }
    }
}

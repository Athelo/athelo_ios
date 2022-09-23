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
    
    // MARK: - Properties
    private var dailyPhaseSumAggregates: [Date: [HealthSleepAggregatedPhaseRecord]] = [:]
    
    // MARK: - Public API
    func fetchPhaseSumAggregateData(from date: Date, step: Int = Constants.dailyDataStep) -> AnyPublisher<Void, Error> {
        let lowerBound = date.dateByAdding(-max(0, step), .day).date
        let upperBound = date
        
        let dateRanges: [QueryDateData] = [.lowerBound(lowerBound, canBeEqual: true), .upperBound(upperBound.dateByAdding(1, .day).date, canBeEqual: true)]
        let request = HealthSleepAggregatedRecordsRequest(granularity: .byPhase, aggregationFunction: .sum, intervalFunction: .day, dates: dateRanges)
        
        return (AtheloAPI.Health.sleepAggregatedRecords(request: request) as AnyPublisher<[HealthSleepAggregatedPhaseRecord], APIError>)
            .handleEvents(receiveOutput: { [weak self] value in
                let groupings = Dictionary(grouping: value.insertingDummyEntries(between: lowerBound, and: upperBound), by: \.date)
                for grouping in groupings {
                    self?.dailyPhaseSumAggregates[day: grouping.key] = grouping.value
                }
            })
            .map({ _ in () })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    func phaseSumAggregateData(at date: Date) -> SleepTimeData? {
        guard let aggregates = dailyPhaseSumAggregates[day: date] else {
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

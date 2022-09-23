//
//  ActivitySummaryDataHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/08/2022.
//

import Combine
import Foundation
import SwiftDate

typealias ActivityDataPoint = ActivitySummaryDataHandler.SummaryDataPoint

final class ActivitySummaryDataHandler {
    // MARK: - Constants
    enum Constants {
        static let dailyDataStep: Int = 20
        static let weeklyDataStep: Int = 60
        static let monthlyDataStep: Int = 100
        
        static let heartRecordPageSize: Int = 1000
    }
    
    // MARK: - Properties
    private var hourlyAggregates: [Date: [ActivityDataPoint]] = [:]
    private var dailyAggregates: [Date: [ActivityDataPoint]] = [:]
    private var weeklyHeartRateAggregates: [Date: [ActivityDataPoint]] = [:]
    
    // MARK: - Public API
    func aggregateData(atDay date: Date) -> [ActivityDataPoint]? {
        dailyAggregates[day: date]
    }
    
    func aggregateData(atHour date: Date) -> [ActivityDataPoint]? {
        hourlyAggregates[hour: date]
    }
    
    func aggregateData(fromDay lowerBound: Date, to upperBound: Date) -> AggregateDataResult {
        var items: [Date: [ActivityDataPoint]] = [:]
        
        var referenceDate = upperBound
        while referenceDate.compare(toDate: lowerBound, granularity: .day) != .orderedAscending {
            guard let aggregates = aggregateData(atDay: referenceDate) else {
                return .failure(referenceDate)
            }
            
            items[referenceDate] = aggregates
            
            referenceDate = referenceDate.dateByAdding(-1, .day).date
        }
        
        return .success(items)
    }
    
    func aggregateData(fromHour lowerBound: Date, to upperBound: Date) -> AggregateDataResult {
        var items: [Date: [ActivityDataPoint]] = [:]
        
        var referenceDate = upperBound
        while referenceDate.compare(toDate: lowerBound, granularity: .hour) != .orderedAscending {
            guard let aggregates = aggregateData(atHour: referenceDate) else {
                return .failure(referenceDate)
            }
            
            items[referenceDate] = aggregates
            
            referenceDate = referenceDate.dateByAdding(-1, .hour).date
        }
        
        return .success(items)
    }
 
    func fetchDailyAggregates(from date: Date, of type: ActivityType, step: Int = Constants.weeklyDataStep) -> AnyPublisher<Void, Error> {
        let lowerBound = date.dateByAdding(-max(0, step), .day).date
        let upperBound = date
        
        let dateRanges: [QueryDateData] = [
            .lowerBound(lowerBound, canBeEqual: true),
            .upperBound(upperBound, canBeEqual: true)
        ]
        
        switch type {
        case .exercise:
            let request = HealthActivityDashboardRequest(aggregationFunction: .sum, intervalFunction: .day, startDate: lowerBound, endDate: upperBound)
            return (AtheloAPI.Health.activityDashboard(request: request) as AnyPublisher<ActivityRecordContainerData, APIError>)
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.handleDailyAggregatedRecords(value.toDashboardItems(), between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .heartRate:
            let request = HealthDashboardRequest(dataType: .heartRate, aggregationFunction: .avg, intervalFunction: .day, dates: dateRanges)
            return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
                .handleEvents(receiveOutput: { [weak self] values in
                    self?.handleDailyHeartRateRecords(values, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .hrv:
            let request = HealthDashboardRequest(dataType: .hrv, aggregationFunction: .avg, intervalFunction: .day, dates: dateRanges)
            return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthHRVDashboardData], APIError>)
                .handleEvents(receiveOutput: { [weak self] values in
                    self?.handleDailyHRVRecords(values, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .steps:
            let request = HealthDashboardRequest(dataType: .steps, aggregationFunction: .sum, intervalFunction: .day, dates: dateRanges)
            return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
                .handleEvents(receiveOutput: { [weak self] values in
                    self?.handleDailyAggregatedRecords(values, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        }
    }
    
    func fetchHourlyAggregates(from date: Date, of type: ActivityType, step: Int = Constants.dailyDataStep) -> AnyPublisher<Void, Error> {
        let lowerBound = date.dateByAdding(-max(0, step), .day).date
        let upperBound = date
        
        let dateRanges: [QueryDateData] = [
            .lowerBound(lowerBound, canBeEqual: true),
            .upperBound(upperBound, canBeEqual: true)
        ]
        
        switch type {
        case .exercise:
            let request = HealthActivityDashboardRequest(aggregationFunction: .sum, intervalFunction: .hour, startDate: lowerBound, endDate: upperBound)
            return (AtheloAPI.Health.activityDashboard(request: request) as AnyPublisher<ActivityRecordContainerData, APIError>)
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.handleHourlyAggregatedRecords(value.toDashboardItems(), between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .heartRate:
            let request = HealthRecordsRequest(dataType: .heartRate, dates: dateRanges, pageSize: Constants.heartRecordPageSize)
            return Publishers.NetworkingPublishers.ListRepeatingPublisher(initialRequest: Deferred { AtheloAPI.Health.records(request: request) as AnyPublisher<ListResponseData<HealthRecordData>, APIError> })
                .handleEvents(receiveOutput: { [weak self] value in
                    self?.handleHourlyHeartRateRecords(value, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .hrv:
            let request = HealthDashboardRequest(dataType: .hrv, aggregationFunction: .avg, intervalFunction: .hour, dates: dateRanges)
            return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthHRVDashboardData], APIError>)
                .handleEvents(receiveOutput: { [weak self] values in
                    self?.handleHourlyHRVRecords(values, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        case .steps:
            let request = HealthDashboardRequest(dataType: .steps, aggregationFunction: .sum, intervalFunction: .hour, dates: dateRanges)
            return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
                .handleEvents(receiveOutput: { [weak self] values in
                    self?.handleHourlyAggregatedRecords(values, between: lowerBound, and: upperBound)
                })
                .eraseTypes()
        }
    }
    
    func fetchHeartRateWeeklyAggregates(from date: Date, step: Int = Constants.weeklyDataStep) -> AnyPublisher<Void, Error> {
        let lowerBound = date.dateByAdding(-max(0, step), .day).date
        let upperBound = date
        
        let dateRanges: [QueryDateData] = [
            .lowerBound(lowerBound, canBeEqual: true),
            .upperBound(upperBound, canBeEqual: true)
        ]
        
        let request = HealthDashboardRequest(dataType: .heartRate, aggregationFunction: .avg, intervalFunction: .hour, dates: dateRanges)
        return (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
            .handleEvents(receiveOutput: { [weak self] values in
                self?.handleWeeklyHeartRateRecords(values, between: lowerBound, and: upperBound)
            })
            .map({ _ in () })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
    
    func heartRateWeeklyAggregateData(atDay date: Date) -> [ActivityDataPoint]? {
        weeklyHeartRateAggregates[day: date]
    }
    
    func heartRateWeeklyAggregateData(fromDay lowerBound: Date, to upperBound: Date) -> AggregateDataResult {
        var items: [Date: [ActivityDataPoint]] = [:]
        
        var referenceDate = upperBound
        while referenceDate.compare(toDate: lowerBound, granularity: .day) != .orderedAscending {
            guard let aggregates = heartRateWeeklyAggregateData(atDay: referenceDate) else {
                return .failure(referenceDate)
            }
            
            items[referenceDate] = aggregates
            
            referenceDate = referenceDate.dateByAdding(-1, .day).date
        }
        
        return .success(items)
    }
    
    // MARK: - Updates
    private func fillEmptyDailyEntries<S: Sequence>(between lowerBound: Date, and upperBound: Date, knownItems: S) where S.Element == Date {
        let expectedEntries = lowerBound.values(to: upperBound, granularity: .day)
        let emptyEntries = Set(expectedEntries).subtracting(Set(knownItems))
        
        for emptyEntry in emptyEntries {
            dailyAggregates[day: emptyEntry] = [.empty(at: emptyEntry)]
        }
    }
    
    private func fillEmptyWeeklyHeartRateEntries<S: Sequence>(between lowerBound: Date, and upperBound: Date, knownItems: S) where S.Element == Date {
        let expectedEntries = lowerBound.values(to: upperBound, granularity: .day)
        let emptyEntries = Set(expectedEntries).subtracting(Set(knownItems))
        
        for emptyEntry in emptyEntries {
            weeklyHeartRateAggregates[day: emptyEntry] = [.empty(at: emptyEntry)]
        }
    }
    
    private func fillEmptyHourlyEntries<S: Sequence>(between lowerBound: Date, and upperBound: Date, knownItems: S) where S.Element == Date {
        let expectedEntries = lowerBound.values(to: upperBound, granularity: .hour)
        let emptyEntries = Set(expectedEntries).subtracting(Set(knownItems))
        
        for emptyEntry in emptyEntries {
            hourlyAggregates[hour: emptyEntry] = [.empty(at: emptyEntry)]
        }
    }
    
    private func handleDailyAggregatedRecords(_ records: [HealthDashboardData], between lowerBound: Date, and upperBound: Date) {
        for record in records.map({ SummaryDataPoint(healthDashboardData: $0) }) {
            dailyAggregates[day: record.date] = [record]
        }
        
        let recordedEntries = Set(records.map({ $0.date.dateAt(.startOfDay).date }) )
        fillEmptyDailyEntries(between: lowerBound, and: upperBound, knownItems: recordedEntries)
    }
    
    private func handleDailyHeartRateRecords(_ records: [HealthDashboardData], between lowerBound: Date, and upperBound: Date) {
        var aggregatedValues: [Date: [ActivityDataPoint]] = [:]
        for record in records {
            let referenceDate = record.date.dateAtStartOf(.day).date
            if aggregatedValues[referenceDate] == nil {
                aggregatedValues[referenceDate] = []
            }
            
            aggregatedValues[referenceDate]?.append(.init(healthDashboardData: record))
        }
        
        for grouping in aggregatedValues {
            dailyAggregates[day: grouping.key] = grouping.value
        }
        
        fillEmptyDailyEntries(between: lowerBound, and: upperBound, knownItems: aggregatedValues.keys)
    }
    
    private func handleDailyHRVRecords(_ records: [HealthHRVDashboardData], between lowerBound: Date, and upperBound: Date) {
        for record in records.map({ SummaryDataPoint(healthHRVDashboardData: $0) }) {
            dailyAggregates[day: record.date] = [record]
        }
        
        let recordedEntries = Set(records.map({ $0.date.dateAt(.startOfDay).date }))
        fillEmptyDailyEntries(between: lowerBound, and: upperBound, knownItems: recordedEntries)
    }
    
    private func handleHourlyAggregatedRecords(_ records: [HealthDashboardData], between lowerBound: Date, and upperBound: Date) {
        for record in records.map({ SummaryDataPoint(healthDashboardData: $0) }) {
            hourlyAggregates[hour: record.date] = [record]
        }
        
        let recordedEntries = Set(records.map({ $0.date.dateAtStartOf(.hour).date }) )
        fillEmptyHourlyEntries(between: lowerBound, and: upperBound, knownItems: recordedEntries)
    }
    
    private func handleHourlyHeartRateRecords(_ records: [HealthRecordData], between lowerBound: Date, and upperBound: Date) {
        var aggregatedValues: [Date: [ActivityDataPoint]] = [:]
        for record in records {
            let referenceDate = record.recordDate.dateAtStartOf(.hour).date
            if aggregatedValues[referenceDate] == nil {
                aggregatedValues[referenceDate] = []
            }
            
            aggregatedValues[referenceDate]?.append(.init(healthRecordData: record))
        }
        
        for grouping in aggregatedValues {
            hourlyAggregates[hour: grouping.key] = grouping.value
        }
        
        fillEmptyHourlyEntries(between: lowerBound, and: upperBound, knownItems: aggregatedValues.keys)
    }
    
    private func handleHourlyHRVRecords(_ records: [HealthHRVDashboardData], between lowerBound: Date, and upperBound: Date) {
        for record in records.map({ SummaryDataPoint(healthHRVDashboardData: $0) }) {
            hourlyAggregates[hour: record.date] = [record]
        }
        
        let recordedEntries = Set(records.map({ $0.date.dateAtStartOf(.hour).date }))
        fillEmptyHourlyEntries(between: lowerBound, and: upperBound, knownItems: recordedEntries)
    }
    
    private func handleWeeklyHeartRateRecords(_ records: [HealthDashboardData], between lowerBound: Date, and upperBound: Date) {
        var aggregatedValues: [Date: [ActivityDataPoint]] = [:]
        for record in records {
            let referenceDate = record.date.dateAt(.startOfDay).date
            if aggregatedValues[referenceDate] == nil {
                aggregatedValues[referenceDate] = []
            }
            
            aggregatedValues[referenceDate]?.append(.init(healthDashboardData: record))
        }
        
        for grouping in aggregatedValues {
            weeklyHeartRateAggregates[day: grouping.key] = grouping.value
        }
        
        fillEmptyWeeklyHeartRateEntries(between: lowerBound, and: upperBound, knownItems: aggregatedValues.keys)
    }
}

// MARK: - Helper extensions
extension ActivitySummaryDataHandler {
    enum AggregateDataResult {
        /// Contains data for requested range.
        case success([Date: [ActivityDataPoint]])
        /// Contains upper bound for which items were missing.
        case failure(Date)
    }
    
    struct SummaryDataPoint {
        let date: Date
        let value: Double
        
        static func empty(at date: Date) -> SummaryDataPoint {
            SummaryDataPoint(date: date, value: 0.0)
        }
        
        private init(date: Date, value: Double) {
            self.date = date
            self.value = value
        }
                
        init(healthDashboardData: HealthDashboardData) {
            self.date = healthDashboardData.date
            self.value = healthDashboardData.value
        }
        
        init(healthRecordData: HealthRecordData) {
            self.date = healthRecordData.recordDate
            self.value = healthRecordData.value
        }
        
        init(healthHRVDashboardData: HealthHRVDashboardData) {
            self.date = healthHRVDashboardData.date
            self.value = healthHRVDashboardData.rmssd
        }
    }
}

private extension ActivityRecordContainerData {
    func toDashboardItems() -> [HealthDashboardData] {
        items.map({ HealthDashboardData(date: $0.key, exerciseData: $0.value) })
    }
}

private extension Date {
    func values(to date: Date, granularity: Calendar.Component) -> [Date] {
        var dates: [Date] = []
        
        var referenceDate = self
        while referenceDate.compare(toDate: date, granularity: granularity) != .orderedDescending {
            dates.append(referenceDate.dateAtStartOf(granularity).date)
            referenceDate = referenceDate.dateByAdding(1, granularity).date
        }
        
        return dates
    }
}

private extension Dictionary where Key == Date {
    subscript(hour date: Date) -> Value? {
        get {
            return self[date.dateAtStartOf(.hour).date]
        }
        set {
            self[date.dateAtStartOf(.hour).date] = newValue
        }
    }
    
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

private extension HealthDashboardData {
    init(date: Date, exerciseData: ActivityRecordData) {
        self.date = date
        self.value = Double(exerciseData.durationSeconds / 60)
    }
}

private extension Publisher {
    func eraseTypes() -> AnyPublisher<Void, Error> {
        map({ _ in () })
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
    }
}

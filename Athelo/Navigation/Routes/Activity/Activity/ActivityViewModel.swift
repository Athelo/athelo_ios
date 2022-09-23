//
//  ActivityViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Combine
import Foundation

final class ActivityViewModel: BaseViewModel {
    // MARK: - Properties
    let activityModel = ActivityTilesModel()
    private var referenceDate = Date()
    
    @Published private(set) var isConnectedToDevice: Bool = IdentityUtility.userData?.hasFitbitUserProfile == true
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        updateWithEmptyData()
        sink()
    }
    
    // MARK: - Updates
    private func refresh() {
        updateHeaderText()
        
        referenceDate = Date()
        
        updateActivityData()
        updateHeartRateData()
        updateHRVData()
        updateStepsData()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoIdentityUtility()
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoIdentityUtility() {
        IdentityUtility.userDataPublisher
            .map({ $0?.hasFitbitUserProfile == true })
            .removeDuplicates()
            .sink { [weak self] in
                self?.isConnectedToDevice = $0
            }.store(in: &cancellables)
    }
    
    private func sinkIntoOwnSubjects() {
        $isConnectedToDevice
            .removeDuplicates()
            .filter({ $0 })
            .sinkDiscardingValue { [weak self] in
                self?.refresh()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateActivityData() {
        let lowerBoundDate = referenceDate.dateByAdding(-6, .day).date
        let request = HealthActivityDashboardRequest(aggregationFunction: .sum, intervalFunction: .day, startDate: lowerBoundDate, endDate: referenceDate)
        
        (AtheloAPI.Health.activityDashboard(request: request) as AnyPublisher<ActivityRecordContainerData, APIError>)
            .map({ [weak self] value -> [GraphColumnItemData] in
                let date = self?.referenceDate ?? Date()
                return value.toGraphColumnItems(from: date.dateByAdding(-6, .day).date, to: date)
            })
            .sink { [weak self] in
                if case .failure(let error) = $0 {
                    self?.message.send(.init(text: error.localizedDescription, type: .error))
                }
            } receiveValue: { [weak self] value in
                DispatchQueue.main.async {
                    self?.activityModel.updateActivityGraphItems(value)
                }
            }.store(in: &cancellables)
    }
    
    private func updateHeaderText() {
        activityModel.updateHeaderText("activity.info.walking.trend.downwards".localized())
    }
    
    private func updateHeartRateData() {
        let lowerBoundDate = referenceDate.dateByAdding(-6, .day).date
        let request = HealthDashboardRequest(dataType: .heartRate, aggregationFunction: .avg, intervalFunction: .day, dates: [.lowerBound(lowerBoundDate, canBeEqual: true)])
        
        (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
            .map({ [weak self] value in
                let date = self?.referenceDate ?? Date()
                return value.extendWithEmptyItems(from: date.dateByAdding(-6, .day).date, to: date).toGraphColumnItems()
            })
            .sink { [weak self] in
                if case .failure(let error) = $0 {
                    self?.message.send(.init(text: error.localizedDescription, type: .error))
                }
            } receiveValue: { [weak self] value in
                DispatchQueue.main.async {
                    self?.activityModel.updateHeartRateGraphItems(value)
                }
            }.store(in: &cancellables)
    }
    
    private func updateHRVData() {
        let lowerBoundDate = referenceDate.dateByAdding(-6, .day).date
        let request = HealthDashboardRequest(dataType: .hrv, aggregationFunction: .avg, intervalFunction: .day, dates: [.lowerBound(lowerBoundDate, canBeEqual: true)])
        
        (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthHRVDashboardData], APIError>)
            .map({
                let referenceDate = lowerBoundDate.dateAt(.startOfDay).date
                return $0.toLinePoints(startingFrom: referenceDate, endingAt: referenceDate.dateByAdding(6, .day).date)
            })
            .sink { [weak self] in
                if case .failure(let error) = $0 {
                    self?.message.send(.init(text: error.localizedDescription, type: .error))
                }
            } receiveValue: { [weak self] value in
                DispatchQueue.main.async {
                    self?.activityModel.updateHRVGraphPoints(value)
                }
            }.store(in: &cancellables)
    }
    
    private func updateStepsData() {
        let lowerBoundDate = referenceDate.dateByAdding(-6, .day).date
        let request = HealthDashboardRequest(dataType: .steps, aggregationFunction: .sum, intervalFunction: .day, dates: [.lowerBound(lowerBoundDate, canBeEqual: true)])
        
        (AtheloAPI.Health.dashboard(request: request) as AnyPublisher<[HealthDashboardData], APIError>)
            .map({ [weak self] value in
                let date = self?.referenceDate ?? Date()
                return value.extendWithEmptyItems(from: date.dateByAdding(-6, .day).date, to: date).toGraphColumnItems()
            })
            .sink { [weak self] in
                if case .failure(let error) = $0 {
                    self?.message.send(.init(text: error.localizedDescription, type: .error))
                }
            } receiveValue: { [weak self] value in
                DispatchQueue.main.async {
                    self?.activityModel.updateStepsGraphItems(value)
                }
            }.store(in: &cancellables)
    }
    
    private func updateWithEmptyData() {
        let lowerBoundDate = referenceDate.dateByAdding(-6, .day).date
        let upperBoundDate = referenceDate
        
        let dashboardData = [HealthDashboardData]().extendWithEmptyItems(from: lowerBoundDate, to: upperBoundDate).toGraphColumnItems()
        let hrvData = [HealthHRVDashboardData]().toLinePoints(startingFrom: lowerBoundDate, endingAt: upperBoundDate)
        
        activityModel.updateActivityGraphItems(dashboardData)
        activityModel.updateHeartRateGraphItems(dashboardData)
        activityModel.updateStepsGraphItems(dashboardData)
        activityModel.updateHRVGraphPoints(hrvData)
    }
}

// MARK: - Helper extensions
private extension ActivityRecordContainerData {
    func toGraphColumnItems(from lowerBound: Date, to upperBound: Date) -> [GraphColumnItemData] {
        var values: [Int] = []
        
        var referenceDate = lowerBound
        while referenceDate.compare(toDate: upperBound, granularity: .day) != .orderedDescending {
            if let validItem = items.first(where: { $0.key.compare(toDate: referenceDate, granularity: .day) == .orderedSame })?.value {
                values.append(validItem.durationSeconds)
            } else {
                values.append(0)
            }
            
            referenceDate = referenceDate.dateByAdding(1, .day).date
        }
        
        return values.enumerated().map({
            GraphColumnItemData(id: $0.offset, color: .withStyle(.lightOlivaceous), value: Double($0.element), label: nil)
        })
    }
}

private extension Array where Element == HealthDashboardData {
    func extendWithEmptyItems(from lowerBound: Date, to upperBound: Date) -> [HealthDashboardData] {
        var items: [HealthDashboardData] = []
        
        var referenceDate = lowerBound
        while referenceDate.compare(toDate: upperBound, granularity: .day) != .orderedDescending {
            if let validItem = first(where: { $0.date.compare(toDate: referenceDate, granularity: .day) == .orderedSame }) {
                items.append(validItem)
            } else {
                items.append(.init(date: referenceDate, value: 0.0))
            }
            
            referenceDate = referenceDate.dateByAdding(1, .day).date
        }
        
        return items
    }
    
    func toGraphColumnItems() -> [GraphColumnItemData] {
        enumerated().map({
            GraphColumnItemData(id: $0.offset, color: .withStyle(.lightOlivaceous), value: $0.element.value, label: nil)
        })
    }
}

private extension Array where Element == HealthHRVDashboardData {
    func extendWithEmptyItems(from lowerBound: Date, to upperBound: Date) -> [HealthHRVDashboardData] {
        var items: [HealthHRVDashboardData] = []
        
        var referenceDate = lowerBound
        while referenceDate.compare(toDate: upperBound, granularity: .day) != .orderedDescending {
            if let validItem = first(where: { $0.date.compare(toDate: referenceDate, granularity: .day) == .orderedSame }) {
                items.append(validItem)
            } else {
                items.append(.empty(at: referenceDate))
            }
            
            referenceDate = referenceDate.dateByAdding(1, .day).date
        }
        
        return items
    }
    
    func toLinePoints(startingFrom startDate: Date, endingAt endDate: Date) -> [GraphLinePointData] {
        var points: [GraphLinePointData] = []
        
        let sorted = self.extendWithEmptyItems(from: startDate, to: endDate).sorted(by: \.date)
        
        var minX = startDate.timeIntervalSince1970
        if let firstItem = sorted.first {
            minX = Swift.min(minX, firstItem.date.timeIntervalSince1970)
        }
        
        var maxX = endDate.timeIntervalSince1970
        if let lastItem = sorted.last {
            maxX = Swift.max(maxX, lastItem.date.timeIntervalSince1970)
        }
        
        for data in sorted {
            if data == sorted.first, data.date.timeIntervalSince1970 > minX {
                points.append(.init(x: 0.0, y: data.rmssd))
            }
            
            points.append(.init(x: data.date.timeIntervalSince1970 - minX, y: data.rmssd))
            
            if data == sorted.last, data.date.timeIntervalSince1970 < maxX {
                points.append(.init(x: maxX - minX, y: data.rmssd))
            }
        }
        
        return points
    }
}

//#warning("Remove data mocking for Activity when bound to services.")
//// MARK: - Mocks
//private extension ActivityViewModel {
//    func mockedGraphEntries() -> [GraphColumnItemData] {
//        (0...6).map({
//            GraphColumnItemData(id: $0, color: .withStyle(.lightOlivaceous), value: .random(in: 0.0...5.0), label: nil)
//        })
//    }
//
//    func mockedLinePoints() -> [GraphLinePointData] {
//        (0...6).map({
//            .init(x: Double($0), y: .random(in: 0.0...1.0))
//        })
//    }
//}

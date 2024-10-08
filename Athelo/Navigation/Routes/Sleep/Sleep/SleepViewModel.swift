//
//  SleepViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Combine
import SwiftDate
import UIKit

final class SleepViewModel: BaseViewModel {
    // MARK: - Properties
    let model = SleepSummaryModel()
    
    @Published private(set) var isConnectedToDevice: Bool = IdentityUtility.userData?.hasFitbitUserProfile == true
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func articleID() -> Int? {
        guard let articleID = ConstantsStore.deviceConfigData()?.applicationSettings?.details?.sleepSettings?.articleID,
              articleID > 0 else {
            return nil
        }
        
        return articleID
    }
    
    private func refresh() {
        guard isConnectedToDevice,
              state.value != .loading else {
            return
        }
        
        state.send(.loading)
        
        let daySumAggregatesRequest = HealthSleepAggregatedRecordsRequest(granularity: .byPhase, aggregationFunction: .sum, intervalFunction: .day, dates: [.lowerBound(Date().dateByAdding(-6, .day).date, canBeEqual: true)])
        
        (AtheloAPI.Health.sleepAggregatedRecords(request: daySumAggregatesRequest) as AnyPublisher<[HealthSleepAggregatedPhaseRecord], APIError>)
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] in
                self?.prepareDisplayedData(basedOn: $0)
            }.store(in: &cancellables)
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
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.refresh()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func prepareDisplayedData(basedOn records: [HealthSleepAggregatedPhaseRecord]) {
        let referenceDate = Date().dateByAdding(-6, .day).date
        let validRecords = records.filter({ $0.date.compare(toDate: referenceDate, granularity: .day) != .orderedAscending })
        
        guard !validRecords.isEmpty else {
            message.send(.init(text: "error.notavailable.watchdata".localized(), type: .error))
            return
        }
        
        var deepSleepTime: TimeInterval = 0.0
        var lightSleepTime: TimeInterval = 0.0
        var remSleepTime: TimeInterval = 0.0
        
        var dates = Set<Date>()
        for record in validRecords {
            switch record.level {
            case .deep:
                deepSleepTime += record.duration
                if deepSleepTime > 0.0 {
                    dates.insert(record.date)
                }
            case .light:
                lightSleepTime += record.duration
                if lightSleepTime > 0.0 {
                    dates.insert(record.date)
                }
            case .rem:
                remSleepTime += record.duration
                if remSleepTime > 0.0 {
                    dates.insert(record.date)
                }
            case .wake:
                break
            }
        }
        
        var avgSleepTime: TimeInterval = 0.0
        let totalTimeSansAwakeStat = deepSleepTime + lightSleepTime + remSleepTime
        
        if totalTimeSansAwakeStat > 0.0, !dates.isEmpty {
            avgSleepTime = totalTimeSansAwakeStat / Double(dates.count)
        }
        
        let todaysRecords = validRecords.filter({ $0.date.compare(toDate: Date(), granularity: .day) == .orderedSame })
        let todaysSleepTimeData = SleepTimeData(awakeTime: todaysRecords.first(where: { $0.level == .wake })?.duration ?? 0.0,
                                                deepSleepTime: todaysRecords.first(where: { $0.level == .deep })?.duration ?? 0.0,
                                                lightSleepTime: todaysRecords.first(where: { $0.level == .light })?.duration ?? 0.0,
                                                remSleepTime: todaysRecords.first(where: { $0.level == .rem })?.duration ?? 0.0)
        
        DispatchQueue.main.async { [weak self] in
            self?.model.updateSummaryData(.init(sleepTime: todaysSleepTimeData), weeklyAvgSleepTime: avgSleepTime)
        }
    }
}

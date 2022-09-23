//
//  SleepSummaryModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Combine
import Foundation

struct SleepSummaryData: Equatable {
    let sleepTime: SleepTimeData
}

final class SleepSummaryModel: ObservableObject {
    // MARK: - Constants
    private enum Constants {
        static let targetSleepTime: TimeInterval = 3600 * 8.5
    }
    
    // MARK: - Properties
    let headerModel: SleepSummaryHeaderModel = SleepSummaryHeaderModel()
    let progressModel: CircularProgressModel = CircularProgressModel(progress: 0.0, text: "nocontent.nodata".localized())
    
    private var avgSleepTime: TimeInterval = 0.0
    
    @Published private(set) var displaysHeader: Bool = false
    @Published private(set) var summaryData: SleepSummaryData?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        sink()
    }
    
    // MARK: - Public API
    func updateSummaryData(_ summaryData: SleepSummaryData, weeklyAvgSleepTime avgSleepTime: TimeInterval) {
        self.summaryData = summaryData
        self.avgSleepTime = avgSleepTime
        
        progressModel.updateProgress(sleepProgress(), text: totalSleepTime)
    }
    
    func sleepTime(for phase: HealthSleepRecordData.SleepPhase) -> String {
        guard let timeData = summaryData?.sleepTime else {
            return formattedSleepTime(0.0)
        }
        
        switch phase {
        case .deep:
            return formattedSleepTime(timeData.deepSleepTime)
        case .light:
            return formattedSleepTime(timeData.lightSleepTime)
        case .rem:
            return formattedSleepTime(timeData.remSleepTime)
        case .wake:
            return formattedSleepTime(timeData.awakeTime)
        }
    }
    
    func sleepProgress() -> Double {
        if let applicationIdealSleepTime = ConstantsStore.deviceConfigData()?.applicationSettings?.details?.sleepSettings?.idealSleepSecs {
            return max(0.0, min(1.0, avgSleepTime / TimeInterval(applicationIdealSleepTime)))
        }
        
        return max(0.0, min(1.0, avgSleepTime / Constants.targetSleepTime))
    }
    
    var totalSleepTime: String {
        formattedSleepTime(avgSleepTime)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoConstantsStore()
    }
    
    private func sinkIntoConstantsStore() {
        ConstantsStore.deviceConfigDataPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                /* ... */
            } receiveValue: { [weak self] configData in
                self?.configureHeader(using: configData)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func formattedSleepTime(_ time: TimeInterval) -> String {
        time.toSleepTimeString()
    }
    
    private func configureHeader(using deviceConfigData: DeviceConfigData?) {
        guard let sleepConfigData = deviceConfigData?.applicationSettings?.details?.sleepSettings,
              sleepConfigData.isNotEmpty else {
            headerModel.clearAll()
            displaysHeader = false
            
            return
        }
        
        headerModel.headerTitle = sleepConfigData.idealSleepText
        if let sleepTime = sleepConfigData.idealSleepSecs, sleepTime > 0 {
            headerModel.headerBody = TimeInterval(sleepTime).toSleepTimeString()
        } else {
            headerModel.headerBody = nil
        }
        
        if sleepConfigData.articleID != nil {
            headerModel.actionTitle = "action.readarticle".localized()
        } else {
            headerModel.actionTitle = nil
        }
        
        displaysHeader = true
    }
}

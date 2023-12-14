//
//  ActivitySummaryModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import CoreGraphics
import Combine
import Foundation
import SwiftUI

final class ActivityTilesModel: ObservableObject {
    // MARK: - Properties
    let activityGraphModel = SmallColumnGraphModel(items: [])
    let heartRateGraphModel = SmallColumnGraphModel(items: [])
    let hrvGraphModel = SmallLineGraphModel(points: [], interpolationMode: .spline)
    let stepsGraphModel = SmallColumnGraphModel(items: [])
    
    let displayedWardModel = SelectedWardModel()
    var hasWardData: Bool {
        displayedWardModel.selectedWard != nil
    }
    
    @Published private(set) var displaysWardData: Bool = false
    @Published private(set) var hasGraphData: Bool = false
    @Published private(set) var headerText: String?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    init() {
        self.headerText = nil
        
        sink()
    }
    
    // MARK: - Public API
    func updateActivityGraphItems(_ items: [GraphColumnItemData]) {
        activityGraphModel.updateItems(items)
    }
    
    func updateDisplayedWardData(_ wardData: ContactData?) {
        displayedWardModel.updateWard(wardData)
    }
    
    func updateHeartRateGraphItems(_ items: [GraphColumnItemData]) {
        heartRateGraphModel.updateItems(items)
    }
    
    func updateHeaderText(_ text: String?) {
        headerText = text
    }
    
    func updateHRVGraphPoints(_ points: [GraphLinePointData]) {
        hrvGraphModel.updatePoints(points)
    }
    
    func updateStepsGraphItems(_ items: [GraphColumnItemData]) {
        stepsGraphModel.updateItems(items)
    }
    
    func updateWardDataVisibility(_ visible: Bool) {
        if displaysWardData != visible {
            displaysWardData = visible
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest4(
            activityGraphModel.validGraphDataPublisher(),
            heartRateGraphModel.validGraphDataPublisher(),
            hrvGraphModel.validGraphDataPublisher(),
            stepsGraphModel.validGraphDataPublisher()
        )
        .map({ $0 || $1 || $2 || $3 })
        .removeDuplicates()
        .sink { [weak self] value in
            if value != self?.hasGraphData {
                withAnimation {
                    self?.hasGraphData = value
                }
            }
        }.store(in: &cancellables)
    }
}

private extension Collection where Element == GraphColumnItemData {
    func hasValidGraphData() -> Bool {
        guard !isEmpty else {
            return false
        }
        
        return contains(where: { !$0.value.isZero })
    }
}

private extension Collection where Element == GraphLinePointData {
    func hasValidGraphData() -> Bool {
        guard !isEmpty else {
            return false
        }
        
        return contains(where: { !$0.y.isZero })
    }
}

private extension SmallColumnGraphModel {
    func validGraphDataPublisher() -> AnyPublisher<Bool, Never> {
        $items
            .map({ $0.hasValidGraphData() })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

private extension SmallLineGraphModel {
    func validGraphDataPublisher() -> AnyPublisher<Bool, Never> {
        $points
            .map({ $0.hasValidGraphData() })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

//
//  SleepSummaryViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Combine
import SwiftUI
import UIKit

final class SleepSummaryViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonNextPeriod: UIButton!
    @IBOutlet private weak var buttonPreviousPeriod: UIButton!
    @IBOutlet private weak var labelDateDescription: UILabel!
    @IBOutlet private weak var labelDateRange: UILabel!
    @IBOutlet private weak var segmentedPickerRange: SegmentedPickerView!
    @IBOutlet private weak var viewNextPeriodButtonShadowContainer: UIView!
    @IBOutlet private weak var viewSummaryContainer: UIView!
    
    private var statsView: SleepStatsContainerView?
    
    // MARK: - Properties
    private let viewModel = SleepSummaryViewModel()
    private var router: SleepSummaryRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
        configureRangeSegmentedPicker()
        configureSummaryContainerView()
    }
    
    private func configureOwnView() {
        title = "navigation.sleep".localized()
    }
    
    private func configureRangeSegmentedPicker() {
        segmentedPickerRange.assignOptions(SleepSummaryFilter.allCases.map({ $0.name }), preselecting: 0)
        
        sinkIntoRangeSegmentedPicker()
    }
    
    private func configureSummaryContainerView() {
        guard statsView == nil else {
            return
        }
        
        let statsView = SleepStatsContainerView(model: viewModel.dataModel)
        
        embedView(statsView, to: viewSummaryContainer)
        
        self.statsView = statsView
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoRangeSegmentedPicker()
        sinkIntoViewModel()
    }
    
    private func sinkIntoRangeSegmentedPicker() {
        segmentedPickerRange.selectedItemPublisher
            .compactMap({
                SleepSummaryFilter.allCases[safe: $0]
            })
            .removeDuplicates()
            .sink(receiveValue: viewModel.dataModel.assignFilter(_:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$canSelectNextRange
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.buttonNextPeriod.isEnabled = $0
                self?.viewNextPeriodButtonShadowContainer.isHidden = !$0
            }.store(in: &cancellables)
        
        viewModel.$rangeDescriptionBody
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelDateDescription)
            .store(in: &cancellables)
        
        viewModel.$rangeDescriptionHeader
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelDateRange)
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction private func nextPeriodButtonTapped(_ sender: Any) {
        viewModel.selectNextRange()
    }
    
    @IBAction private func previousPeriodButtonTapped(_ sender: Any) {
        viewModel.selectPreviousRange()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SleepSummaryViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .sleep
    }
}

// MARK: Routable
extension SleepSummaryViewController: Routable {
    func assignRouter(_ router: SleepSummaryRouter) {
        self.router = router
    }
}

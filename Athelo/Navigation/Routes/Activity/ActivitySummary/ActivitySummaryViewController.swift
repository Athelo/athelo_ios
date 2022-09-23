//
//  ActivitySummaryViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Combine
import UIKit

typealias ActivitySummaryFilter = ActivitySummaryViewController.FilterType

final class ActivitySummaryViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonNextPeriod: UIButton!
    @IBOutlet private weak var buttonPreviousPeriod: UIButton!
    @IBOutlet private weak var labelDateDescription: UILabel!
    @IBOutlet private weak var labelDateRange: UILabel!
    @IBOutlet private weak var segmentedPickerFilter: SegmentedPickerView!
    @IBOutlet private weak var viewNextPeriodButtonShadowContainer: UIView!
    @IBOutlet private weak var viewSummaryContainer: UIView!
    
    private var summaryView: ActivitySummaryView?
    
    // MARK: - Properties
    private let viewModel = ActivitySummaryViewModel()
    private var router: ActivitySummaryRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureFilterSegmentedPicker()
        configureSummaryContainerView()
    }
    
    private func configureFilterSegmentedPicker() {
        segmentedPickerFilter.assignOptions(ActivitySummaryFilter.allCases.map({ $0.name }), preselecting: ActivitySummaryFilter.allCases.firstIndex(of: viewModel.dataModel.filter) ?? 0)
    }
    
    private func configureSummaryContainerView() {
        guard summaryView == nil else {
            return
        }
        
        let summaryView = ActivitySummaryView(model: viewModel.dataModel)
        
        embedView(summaryView, to: viewSummaryContainer)
        
        self.summaryView = summaryView
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoFilterSegmentedPicker()
        sinkIntoViewModel()
    }
    
    private func sinkIntoFilterSegmentedPicker() {
        segmentedPickerFilter.selectedItemPublisher
            .compactMap({ ActivitySummaryFilter.allCases[safe: $0] })
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewModel.dataModel.updateFilter($0)
            }.store(in: &cancellables)
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

// MARK: - Helper extensions
extension ActivitySummaryViewController {    
    enum FilterType: String, CaseIterable, Equatable {
        case day
        case week
        case month
        
        var name: String {
            "activity.filter.\(rawValue)".localized()
        }
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension ActivitySummaryViewController: Configurable {
    func assignConfigurationData(_ configurationData: ActivityType) {
        viewModel.dataModel.updateActivityType(configurationData)
        
        title = configurationData.name
    }
}

// MARK: Navigable
extension ActivitySummaryViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .activity
    }
}

// MARK: Routable
extension ActivitySummaryViewController: Routable {
    func assignRouter(_ router: ActivitySummaryRouter) {
        self.router = router
    }
}

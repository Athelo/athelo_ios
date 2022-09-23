//
//  SymptomDescriptionViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import UIKit

typealias SymptomDescriptionConfigurationData = SymptomDescriptionViewController.ConfigurationData

final class SymptomDescriptionViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonSymptomChronology: UIButton!
    @IBOutlet private weak var viewDescriptionContainer: UIView!
    @IBOutlet private weak var viewBlendingGradient: UIView!
    @IBOutlet private weak var viewNoContent: UIView!
    
    private var descriptionView: SymptomDescriptionListView?
    // MARK: - Properties
    private let viewModel = SymptomDescriptionViewModel()
    private var router: SymptomDescriptionRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configure
    private func configure() {
        configureDescriptionContainerView()
        configureNoContentView()
        configureOwnView()
    }
    
    private func configureDescriptionContainerView() {
        guard descriptionView == nil else {
            return
        }
        
        let descriptionView = SymptomDescriptionListView(model: viewModel.itemModel)
        
        embedView(descriptionView, to: viewDescriptionContainer)
        
        self.descriptionView = descriptionView
    }
    
    private func configureNoContentView() {
        viewNoContent.alpha = 0.0
    }
    
    private func configureOwnView() {
        updateTitle()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$displaysChronologyButton
            .removeDuplicates()
            .map({ !$0 })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.buttonSymptomChronology.isHidden = $0
                self?.viewBlendingGradient.isHidden = $0
                self?.descriptionView?.model.updateExtendedBottomContentState($0)
            })
            .store(in: &cancellables)
        
        viewModel.itemModel.$entries
            .map({ $0.first?.name })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.updateTitle()
            }.store(in: &cancellables)
        
        viewModel.state
            .map({ $0 == .loaded })
            .combineLatest(
                viewModel.itemModel.$entries
                    .map({ $0.count <= 0 })
            )
            .map({ !($0 && $1) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.viewNoContent.alpha = value ? 0.0 : 1.0
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func updateTitle() {
        guard !viewModel.itemModel.entries.isEmpty else {
            return
        }
        
        if viewModel.itemModel.entries.count > 1 {
            title = "navigation.symptom.description".localized()
        } else {
            title = viewModel.itemModel.entries.first?.name
        }
    }
    
    // MARK: - Actions
    @IBAction private func symptomChronologyButtonTapped(_ sender: Any) {
        guard let configurationData = viewModel.configurationData else {
            return
        }
        
        router?.navigateToSymptomChronology(using: configurationData)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension SymptomDescriptionViewController: Configurable {
    struct ConfigurationData {
        let modelListData: ModelConfigurationListData<SymptomData>
        let displaysChronologyButton: Bool
        
        init(modelListData: ModelConfigurationListData<SymptomData>, displaysChronologyButton: Bool = true) {
            self.modelListData = modelListData
            self.displaysChronologyButton = displaysChronologyButton
        }
    }
    
    func assignConfigurationData(_ configurationData: SymptomDescriptionConfigurationData) {
        viewModel.assignConfigurationData(configurationData)
    }
}

// MARK: Navigable
extension SymptomDescriptionViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .symptom
    }
}

// MARK: Routable
extension SymptomDescriptionViewController: Routable {
    func assignRouter(_ router: SymptomDescriptionRouter) {
        self.router = router
    }
}

//
//  SymptomChronologyViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import UIKit

final class SymptomChronologyViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewListContainer: UIView!
    
    private var listView: SymptomsDailyListView?
    
    // MARK: - Properties
    private let viewModel = SymptomChronologyViewModel()
    private var router: SymptomChronologyRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureListContainerView()
        configureOwnView()
    }
    
    private func configureListContainerView() {
        guard listView == nil else {
            return
        }
        
        let listView = SymptomsDailyListView(model: viewModel.itemModel)
        
        embedView(listView, to: viewListContainer)
        
        self.listView = listView
    }
    
    private func configureOwnView() {
        title = "navigation.symptom.chronology".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoListView()
        sinkIntoViewModel()
    }
    
    private func sinkIntoListView() {
        listView?.loadMorePublisher
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.viewModel.loadMore()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        viewModel.message
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in self?.view.window != nil })
            .sink { [weak self] in
                self?.displayMessage($0.text, type: $0.type)
            }.store(in: &cancellables)
        
        viewModel.state
            .receive(on: DispatchQueue.main)
            .filter({ [weak self] _ in self?.view.window != nil })
            .sink { [weak self] in
                switch $0 {
                case .error(let error):
                    AppRouter.current.windowOverlayUtility.hideLoadingView()
                    
                    let message = error.toInfoMessageData()
                    AppRouter.current.windowOverlayUtility.displayMessage(message.text, type: message.type)
                case .initial:
                    break
                case .loaded:
                    AppRouter.current.windowOverlayUtility.hideLoadingView()
                case .loading:
                    if self?.viewModel.canLoadMore == false {
                        AppRouter.current.windowOverlayUtility.displayLoadingView()
                    }
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension SymptomChronologyViewController: Configurable {
    func assignConfigurationData(_ configurationData: ModelConfigurationListData<SymptomData>) {
        viewModel.assignConfigurationData(configurationData)
    }
}

// MARK: Navigable
extension SymptomChronologyViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .symptom
    }
}

// MARK: Routable
extension SymptomChronologyViewController: Routable {
    func assignRouter(_ router: SymptomChronologyRouter) {
        self.router = router
    }
}

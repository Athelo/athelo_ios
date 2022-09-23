//
//  SymptomListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Combine
import UIKit
import SwiftUI

final class SymptomListViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var segmentedPickerViewFilters: SegmentedPickerView!
    @IBOutlet private weak var viewListContainer: UIView!
    @IBOutlet private weak var viewNoContent: UIView!
    
    private var symptomListView: SymptomListView?
    
    // MARK: - Properties
    private let viewModel = SymptomListViewModel()
    private var router: SymptomListRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }

    // MARK: - Configure
    private func configure() {
        configureFiltersSegmentedPickerView()
        configureListContainerView()
        configureNoContentView()
        configureOwnView()
    }
    
    private func configureFiltersSegmentedPickerView() {
        segmentedPickerViewFilters.assignOptions(SymptomListViewModel.Filter.allCases.map({ $0.name }), preselecting: viewModel.filter.rawValue)
    }
    
    private func configureListContainerView() {
        guard symptomListView == nil else {
            return
        }
        
        let listView = SymptomListView(model: viewModel.itemsModel) { [weak self] value in
            DispatchQueue.main.async {
                let configuration: ModelConfigurationListData<SymptomData> = self?.viewModel.detailsConfigurationData(for: value) ?? .id([value.id])
                self?.router?.navigateToSymptomDescription(using: .init(modelListData: configuration))
            }
        }
        
        let listViewController = UIHostingController(rootView: listView)
        
        listViewController.view.translatesAutoresizingMaskIntoConstraints = false
        listViewController.view.backgroundColor = .clear
        
        addChild(listViewController)
        viewListContainer.addSubview(listViewController.view)
        
        NSLayoutConstraint.activate([
            listViewController.view.topAnchor.constraint(equalTo: viewListContainer.topAnchor),
            listViewController.view.bottomAnchor.constraint(equalTo: viewListContainer.bottomAnchor),
            listViewController.view.leftAnchor.constraint(equalTo: viewListContainer.leftAnchor),
            listViewController.view.rightAnchor.constraint(equalTo: viewListContainer.rightAnchor)
        ])
        
        listViewController.didMove(toParent: self)
        
        symptomListView = listView
    }
    
    private func configureNoContentView() {
        viewNoContent.alpha = 0.0
    }
    
    private func configureOwnView() {
        title = "navigation.symptom.list".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoFiltersSegmentedPickerView()
        sinkIntoViewModel()
    }
    
    private func sinkIntoFiltersSegmentedPickerView() {
        segmentedPickerViewFilters.selectedItemPublisher
            .compactMap({ SymptomListViewModel.Filter(rawValue: $0) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak viewModel = viewModel] in
                viewModel?.selectFilter($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.state
            .map({ $0 == .loaded })
            .combineLatest(
                viewModel.itemsModel.$entries
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
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SymptomListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .symptom
    }
}

// MARK: Routable
extension SymptomListViewController: Routable {
    func assignRouter(_ router: SymptomListRouter) {
        self.router = router
    }
}

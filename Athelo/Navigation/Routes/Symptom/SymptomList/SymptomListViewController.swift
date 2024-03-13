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
    }

    // MARK: - Configure
    private func configure() {
        configureFiltersSegmentedPickerView()
        configureRegisterSymptomView(for: .dailytracker)
        configureOwnView()
    }
    
    private func configureFiltersSegmentedPickerView() {
        segmentedPickerViewFilters.assignOptions(SymptomListViewModel.Filter.allCases.map({ $0.name }), preselecting: viewModel.filter.rawValue)
    }
    
   
    
    private func configureRegisterSymptomView(for tab: SymptomListViewModel.Filter) {
        viewListContainer.subviews.forEach{$0.removeFromSuperview()}
        var viewController = UIViewController()
        if tab == .dailytracker {
            let registerRouter = RegisterSymptomsRouter(navigationController: router!.navigationController!)
            viewController = RegisterSymptomsViewController.viewController(router: registerRouter)
        }else{
            let registerRouter = SymptomChronologyRouter(navigationController: router!.navigationController!)
            viewController = SymptomChronologyViewController.viewController(router: registerRouter)
            
        }
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.backgroundColor = .clear
        
        addChild(viewController)
        viewListContainer.addSubview(viewController.view)
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: viewListContainer.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: viewListContainer.bottomAnchor),
            viewController.view.leftAnchor.constraint(equalTo: viewListContainer.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: viewListContainer.rightAnchor)
        ])
        
        viewController.didMove(toParent: self)
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
            .sink { [weak self] in
                self?.configureRegisterSymptomView(for: $0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.state
            .map({ $0 == .loaded })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { value in }.store(in: &cancellables)
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

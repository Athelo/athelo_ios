//
//  ActivityViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Combine
import UIKit

final class ActivityViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewSummaryContainer: UIView!
    @IBOutlet private weak var viewWatchConnectionContainer: UIView!
    
    private weak var noWatchViewController: NoWatchViewController?
    private var summaryView: ActivityTilesView?
    
    // MARK: - Propeties
    private let viewModel = ActivityViewModel()
    private var router: ActvityRouter?
    
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
        configureSummaryContainerView()
        configureWatchConnectionContainerView()
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    private func configureSummaryContainerView() {
        guard summaryView == nil else {
            return
        }
        
        let summaryView = ActivityTilesView(model: viewModel.activityModel) { tile in
            DispatchQueue.main.async { [weak self] in
                self?.router?.navigateToActivitySummary(using: tile.activityType)
            }
        }
        
        embedView(summaryView, to: viewSummaryContainer)
        
        self.summaryView = summaryView
    }
    
    private func configureWatchConnectionContainerView() {
        viewWatchConnectionContainer.alpha = viewModel.isConnectedToDevice ? 0.0 : 1.0
        
        guard noWatchViewController == nil else {
            return
        }
        
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = NoWatchRouter(navigationController: navigationController)
        let noWatchViewController = NoWatchViewController.viewController(router: router)
        
        noWatchViewController.view.translatesAutoresizingMaskIntoConstraints = false
        noWatchViewController.view.backgroundColor = .withStyle(.background)
        
        viewWatchConnectionContainer.addSubview(noWatchViewController.view)
        addChild(noWatchViewController)
        
        noWatchViewController.view.stretchToSuperview()
        
        noWatchViewController.didMove(toParent: self)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$isConnectedToDevice
            .removeDuplicates()
            .map({ ($0 ? 0.0 : 1.0) as CGFloat })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard value != self?.viewWatchConnectionContainer.alpha else {
                    return
                }
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.viewWatchConnectionContainer.alpha = value
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension ActivityViewController: Navigable {
    static var storyboardScene: StoryboardScene{
        .activity
    }
}

// MARK: Routable
extension ActivityViewController: Routable {
    func assignRouter(_ router: ActvityRouter) {
        self.router = router
    }
}

// MARK: - Helper extensions
private extension ActivityTilesView.Tile {
    var activityType: ActivityType {
        switch self {
        case .activity:
            return .exercise
        case .heartRate:
            return .heartRate
        case .hrv:
            return .hrv
        case .steps:
            return .steps
        }
    }
}

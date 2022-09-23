//
//  SplashViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import UIKit

final class SplashViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var labelLoading: UILabel!
    @IBOutlet private weak var stackViewLoading: UIStackView!
    
    // MARK: - Properties
    private let viewModel = SplashViewModel()
    private var router: SplashRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureLoadingStackView()
    }
    
    private func configureLoadingStackView() {
        stackViewLoading.alpha = 0.0
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoDelayTimer()
        sinkIntoViewModel()
    }
    
    private func sinkIntoDelayTimer() {
        Timer.publish(every: 0.5, on: .main, in: .default)
            .autoconnect()
            .first()
            .sinkDiscardingValue { [weak self] in
                UIView.animate(withDuration: 0.2) {
                    self?.stackViewLoading.alpha = 1.0
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$route
            .compactMap({ $0 })
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak router = router] route in
                router?.resolveRoute(route)
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SplashViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .splash
    }
}

// MARK: Routable
extension SplashViewController: Routable {
    typealias RouterType = SplashRouter
    
    func assignRouter(_ router: SplashRouter) {
        self.router = router
    }
}

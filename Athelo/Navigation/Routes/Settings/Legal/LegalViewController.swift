//
//  LegalViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Combine
import SwiftUI
import UIKit

typealias LegalConfigurationData = LegalViewController.ConfigurationData

final class LegalViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet weak var viewDescriptionContainer: UIView!
    @IBOutlet weak var viewNoContent: UIView!
    
    private var descriptionView: DescriptionView?
    
    // MARK: - Properties
    private let viewModel = LegalViewModel()
    private var router: LegalRouter?
    
    private var onDisappear: (() -> Void)? = nil
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            onDisappear?()
        }
    }
    
    // MARK: - Public API
    func assignOnDisapperAction(_ action: @escaping () -> Void) {
        onDisappear = action
    }
    
    // MARK: - Configuration
    private func configure() {
        configureDescriptionContainerView()
        configureNoContentView()
    }
    
    private func configureDescriptionContainerView() {
        guard descriptionView == nil else {
            return
        }
        
        let descriptionView = DescriptionView(model: viewModel.model, font: .withStyle(.paragraph)) { [weak self] url in
            self?.router?.displayURL(url)
        }
        
        let hostingViewController = UIHostingController(rootView: descriptionView)
        
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingViewController.view.backgroundColor = .clear
        
        addChild(hostingViewController)
        viewDescriptionContainer.insertSubview(hostingViewController.view, at: 0)
        
        NSLayoutConstraint.activate([
            hostingViewController.view.topAnchor.constraint(equalTo: viewDescriptionContainer.topAnchor),
            hostingViewController.view.bottomAnchor.constraint(equalTo: viewDescriptionContainer.bottomAnchor),
            hostingViewController.view.leftAnchor.constraint(equalTo: viewDescriptionContainer.leftAnchor),
            hostingViewController.view.rightAnchor.constraint(equalTo: viewDescriptionContainer.rightAnchor)
        ])
        
        hostingViewController.didMove(toParent: self)
        
        self.descriptionView = descriptionView
    }
    
    private func configureNoContentView() {
        viewNoContent.alpha = 0.0
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.state
            .toError(of: Error.self)
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                UIView.animate(withDuration: 0.2) {
                    self?.viewDescriptionContainer.alpha = 0.0
                    self?.viewNoContent.alpha = 1.0
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension LegalViewController: Configurable {
    struct ConfigurationData {
        enum Source {
            case text(String)
            case publisher(AnyPublisher<String, Error>)
        }
        
        let title: String
        let source: Source
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        viewModel.assignConfigurationData(configurationData)
        
        title = configurationData.title
    }
}

// MARK: Navigable
extension LegalViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .settings
    }
}

// MARK: Routable
extension LegalViewController: Routable {
    func assignRouter(_ router: LegalRouter) {
        self.router = router
    }
}

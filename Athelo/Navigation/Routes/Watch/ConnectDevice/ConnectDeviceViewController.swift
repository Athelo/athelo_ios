//
//  ConnectDeviceViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Combine
import UIKit

final class ConnectDeviceViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonAction: UIButton!
    @IBOutlet private weak var buttonSkip: UIButton!
    @IBOutlet private weak var imageViewConnectionFailure: UIImageView!
    @IBOutlet private weak var imageViewConnectionSuccess: UIImageView!
    @IBOutlet private weak var imageViewNotConnected: UIImageView!
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var viewConnectionStatus: UIView!
    
    // MARK: - Properties
    private let viewModel = ConnectDeviceViewModel()
    private var router: ConnectDeviceRouter?
    
    private var skipAction: (() -> Void)?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureConnectionIndicatorViews()
        configureOwnView()
        configureSkipButton()
    }
    
    private func configureConnectionIndicatorViews() {
        imageViewConnectionFailure.alpha = 0.0
        imageViewConnectionSuccess.alpha = 0.0
        imageViewNotConnected.alpha = 0.0
        viewConnectionStatus.alpha = 0.0
    }
    
    private func configureOwnView() {
        navigationItem.displayAppLogo()
        
        cancellables.append(navigationItem.displayUserAvatar(with: router))
    }
    
    private func configureSkipButton() {
        buttonSkip.isHidden = skipAction == nil
        buttonSkip.alpha = buttonSkip.isHidden ? 0.0 : 1.0
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$actionTitle
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak button = buttonAction] value in
                UIView.performWithoutAnimation {
                    button?.setTitle(value, for: .normal)
                }
            }.store(in: &cancellables)
        
        viewModel.$headerText
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: labelHeader)
            .store(in: &cancellables)
        
        viewModel.$status
            .compactMap({ $0 })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.animateConnectionStateChange(to: $0)
            }.store(in: &cancellables)
        
        viewModel.$status
            .map({ $0 == .connected })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard self?.skipAction != nil,
                      self?.buttonAction.isHidden != value else {
                    return
                }
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState]) {
                    self?.buttonSkip.isHidden = value
                    self?.buttonSkip.alpha = value ? 0.0 : 1.0
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func animateConnectionStateChange(to state: ConnectDeviceViewModel.ConnectionStatus) {
        let animationTime = shouldAnimateConnectionStateChange() ? 0.3 : 0.0
        UIView.animate(withDuration: animationTime, delay: 0.0, options: [.beginFromCurrentState]) { [weak self] in
            self?.imageViewNotConnected.alpha = state == .notEstablished ? 1.0 : 0.0
            self?.viewConnectionStatus.alpha = state != .notEstablished ? 1.0 : 0.0
            self?.imageViewConnectionFailure.alpha = state == .connectionFailed ? 1.0 : 0.0
            self?.imageViewConnectionSuccess.alpha = state == .connected ? 1.0 : 0.0
        }
    }
    
    private func displayFitbitAuthURL(_ url: URL) {
        router?.displayURL(.init(url: url, privateSession: true, delegate: self))
    }
    
    private func shouldAnimateConnectionStateChange() -> Bool {
        [imageViewNotConnected, viewConnectionStatus].contains(where: { $0?.alpha.isZero == false })
    }
    
    // MARK: - Actions
    @IBAction private func actionButtonTapped(_ sender: Any) {
        guard let status = viewModel.status,
              let deviceType = viewModel.deviceType else {
            return
        }
        
        switch deviceType {
        case .fitbit:
            switch status {
            case .connectionFailed, .notEstablished:
                viewModel.fitbitSyncURLPublisher()
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        /* ... */
                    } receiveValue: { [weak self] url in
                        self?.displayFitbitAuthURL(url)
                    }.store(in: &cancellables)
            case .connected:
                router?.navigateToActivity()
            }
        case .appleWatch:
            displayMessage("message.comingsoon".localized(), type: .plain)
        }
    }
    
    @IBAction private func skipButtonTapped(_ sender: Any) {
        guard let skipAction = skipAction else {
            fatalError("Invalid configuration of \(ConnectDeviceViewController.self) - missing skip action.")
        }

        skipAction()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension ConnectDeviceViewController: Configurable {
    struct ConfigurationData {
        let deviceType: DeviceType
        let skipAction: (() -> Void)?
        
        init(deviceType: DeviceType, skipAction: (() -> Void)? = nil) {
            self.deviceType = deviceType
            self.skipAction = skipAction
        }
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        viewModel.assignDeviceType(configurationData.deviceType)
        skipAction = configurationData.skipAction
    }
}

// MARK: Navigable
extension ConnectDeviceViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .watch
    }
}

// MARK: Routable
extension ConnectDeviceViewController: Routable {
    func assignRouter(_ router: ConnectDeviceRouter) {
        self.router = router
    }
}

// MARK: WebViewControllerDelegate
extension ConnectDeviceViewController: WebViewControllerDelegate {
    func webViewControllerAsksToDecidePolicyForDeeplink(_ deeplink: DeeplinkType) -> Bool {
        viewModel.handleDeeplink(deeplink)
    }
}

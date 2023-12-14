//
//  MyDeviceViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 25/07/2022.
//

import Combine
import UIKit

final class MyDeviceViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var viewGradientContainer: UIView!
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Properties
    private let viewModel = MyDeviceViewModel()
    private var router: MyDeviceRouter?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureGradientContainerView()
        configureOwnView()
    }
    
    private func configureGradientContainerView() {
        var imageData: BottomClippedGradientViewImageData?
        if let image = UIImage(named: "smartwatchConnected") {
            imageData = .init(image: image, shouldClip: true, yOffset: -28.0)
        }
        
        displayBackgroundGradient(in: viewGradientContainer, imageData: imageData)
    }
    
    private func configureOwnView() {
        title = "My Device"
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoViewModel()
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .first()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.store(in: &cancellables)
        
        viewModel.forceFitbitRemovalPublisher
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.displayForcedDeviceDisconnectionPrompt()
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction private func disconnectMyDeviceButtonTapped(_ sender: Any) {
        displayDeviceDisconnectionPrompt()
    }
    
    // MARK: - Updates
    private func displayDeviceDisconnectionPrompt() {
        let disconnectAction = PopupActionData(title: "action.disconnect".localized(), customStyle: .destructive) { [weak self] in
            self?.viewModel.disconnectDevice()
        }
        let cancelAction = PopupActionData(title: "action.cancel".localized())
        
        let popupConfigurationData = PopupConfigurationData(template: .disconnectDevice, primaryAction: disconnectAction, secondaryAction: cancelAction)
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupConfigurationData)
    }
    
    private func displayForcedDeviceDisconnectionPrompt() {
        let disconnectAction = PopupActionData(title: "action.remove".localized(), customStyle: .destructive) { [weak self] in
            self?.viewModel.disconnectDevice(forced: true)
        }
        let cancelAction = PopupActionData(title: "action.cancel".localized())
        
        let popupConfigurationData = PopupConfigurationData(
            title: "popup.disconnectdevice.title".localized(),
            message: "popup.disconnectdevice.message.forced".localized(),
            primaryAction: disconnectAction,
            secondaryAction: cancelAction
        )
        AppRouter.current.windowOverlayUtility.displayPopupView(with: popupConfigurationData)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension MyDeviceViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .watch
    }
}

// MARK: Routable
extension MyDeviceViewController: Routable {
    func assignRouter(_ router: MyDeviceRouter) {
        self.router = router
    }
}

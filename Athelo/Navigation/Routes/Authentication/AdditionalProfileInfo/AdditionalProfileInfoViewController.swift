//
//  AdditionalProfileInfoViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class AdditionalProfileInfoViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonSave: UIButton!
    @IBOutlet private weak var formTextFieldName: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = AdditionalProfileInfoViewModel()
    private var router: AdditionalProfileInfoRouter?
    
    private var cancellables: [AnyCancellable] = []
    private var userTypeInputCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        router?.authenticationUpdateEventsSubject.send(.legalLabelVisibilityChanged(false))
    }
    
    // MARK: - Configuration
    private func configure() {
        configureOwnView()
        configureNameFormTextField()
    }
    
    private func configureOwnView() {
        navigationItem.hidesBackButton = true
        title = "navigation.auth.additionalinfo".localized()
    }
    
    private func configureNameFormTextField() {
        formTextFieldName.autocapitalizationType = .words
        formTextFieldName.autocorrectionType = .no
        formTextFieldName.returnKeyType = .next
        formTextFieldName.textContentType = .name
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoKeyboardChanges()
        sinkIntoNameFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoNameFormTextField() {
        formTextFieldName.returnPublisher
            .sink { [weak self] in
                self?.view.endEditing(true)
            }.store(in: &cancellables)
        
        formTextFieldName.currentTextPublisher
            .sink(receiveValue: viewModel.assignName(_:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] in
                if let self = self {
                    let targetOffset = $0.offsetFromScreenBottom > 0.0 ? 0.0 : -84.0
                    if targetOffset != self.constraintStackViewContentBottom.constant {
                        self.constraintStackViewContentBottom.constant = targetOffset
                    }
                    
                    self.adjustBottomOffset(using: self.constraintScrollViewContentBottom, keyboardChangeData: $0, additionalOffset: 84.0)
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        viewModel.$isValid
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak button = buttonSave] in
                button?.isEnabled = $0
            }.store(in: &cancellables)
        
        viewModel.state
            .sink { [weak router = router] in
                router?.authenticationUpdateEventsSubject.send(.modelStateChanged($0))
            }.store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.router?.navigateOnSuccessfulAuthentication()
            }.store(in: &cancellables)
        
        if navigationController == nil || navigationController?.viewControllers.first === self {
            viewModel.state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    switch $0 {
                    case .error(let error):
                        AppRouter.current.windowOverlayUtility.hideLoadingView()
                        
                        if !(error is AuthenticationPingError) {
                            self?.displayError(error)
                        }
                    case .loaded:
                        AppRouter.current.windowOverlayUtility.hideLoadingView()
                    case .loading:
                        AppRouter.current.windowOverlayUtility.displayLoadingView()
                    case .initial:
                        break
                    }
                }.store(in: &cancellables)
        }
    }
    
    // MARK: - Updates
    @IBAction private func saveButtonTapped(_ sender: Any) {
        formTextFieldName.clearErrorMarking()
        
        view.endEditing(true)
        dismissMessage()
        
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension AdditionalProfileInfoViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .authentication
    }
}

// MARK: Routable
extension AdditionalProfileInfoViewController: Routable {
    typealias RouterType = AdditionalProfileInfoRouter
    
    func assignRouter(_ router: AdditionalProfileInfoRouter) {
        self.router = router
    }
}

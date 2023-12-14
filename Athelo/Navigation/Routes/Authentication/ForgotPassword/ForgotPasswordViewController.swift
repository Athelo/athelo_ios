//
//  AuthentiationForgotPasswordViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class ForgotPasswordViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonResetPassword: StyledButton!
    @IBOutlet private weak var formTextFieldEmail: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = ForgotPasswordViewModel()
    private var router: ForgotPasswordRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        router?.authenticationUpdateEventsSubject.send(.legalLabelVisibilityChanged(true))
    }
    
    // MARK: - Configuration
    private func configure() {
        configureEmailFormTextField()
        configureOwnView()
    }
    
    private func configureEmailFormTextField() {
        formTextFieldEmail.text = viewModel.email
        
        formTextFieldEmail.autocapitalizationType = .none
        formTextFieldEmail.autocorrectionType = .no
        formTextFieldEmail.keyboardType = .emailAddress
        formTextFieldEmail.returnKeyType = .done
        formTextFieldEmail.textContentType = .emailAddress
    }
    
    private func configureOwnView() {
        title = "navigation.password.reset".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoEmailFormTextField()
        sinkIntoKeyboardChanges()
        sinkIntoViewModel()
    }
    
    private func sinkIntoEmailFormTextField() {
        formTextFieldEmail.returnPublisher
            .sinkDiscardingValue { [weak textField = formTextFieldEmail] in
                textField?.resignFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldEmail.currentTextPublisher
            .removeDuplicates()
            .sink(receiveValue: viewModel.assignEmail(_:))
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
        viewModel.$formErrors
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.displayFormErrors($0)
            }.store(in: &cancellables)
        
        viewModel.$isValid
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak button = buttonResetPassword] in
                button?.isEnabled = $0
            }.store(in: &cancellables)
        
        viewModel.state
            .sink { [weak self] in
                self?.router?.authenticationUpdateEventsSubject.send(.modelStateChanged($0))
            }.store(in: &cancellables)
        
        viewModel.successMessagePublisher
            .filter({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.displayMessage($0, type: .success)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayFormErrors(_ formErrors: [AuthFormError]) {
        guard !formErrors.isEmpty else {
            return
        }
        
        for formError in formErrors {
            switch formError {
            case .confirmPassword, .oldPassword, .password:
                break
            case .email:
                formTextFieldEmail.markError()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func resetPasswordButtonTapped(_ sender: Any) {
        formTextFieldEmail.clearErrorMarking()
        
        view.endEditing(true)
        dismissMessage()
        
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension ForgotPasswordViewController: Configurable {
    struct ConfigurationData {
        let email: String?
    }
    
    typealias ConfigurationDataType = ConfigurationData
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        viewModel.assignEmail(configurationData.email)
    }
}

// MARK: Navigable
extension ForgotPasswordViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .authentication
    }
}

// MARK: Routable
extension ForgotPasswordViewController: Routable {
    typealias RouterType = ForgotPasswordRouter
    
    func assignRouter(_ router: ForgotPasswordRouter) {
        self.router = router
    }
}

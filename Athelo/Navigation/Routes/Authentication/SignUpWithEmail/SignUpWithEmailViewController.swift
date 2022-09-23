//
//  SignUpWithEmailViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class SignUpWithEmailViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonRegister: StyledButton!
    @IBOutlet private weak var formTextFieldConfirmPassword: FormTextField!
    @IBOutlet private weak var formTextFieldEmail: FormTextField!
    @IBOutlet private weak var formTextFieldPassword: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = SignUpWithEmailViewModel()
    private var router: SignUpWithEmailRouter?
    
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
        configureConfirmPasswordFormTextField()
        configureEmailFormTextField()
        configureOwnView()
        configurePasswordFormTextField()
    }
    
    private func configureConfirmPasswordFormTextField() {
        formTextFieldConfirmPassword.returnKeyType = .done
        formTextFieldConfirmPassword.textContentType = .password
        
        formTextFieldConfirmPassword.enableSecureTextEntry()
    }
    
    private func configureEmailFormTextField() {
        formTextFieldEmail.autocapitalizationType = .none
        formTextFieldEmail.autocorrectionType = .no
        formTextFieldEmail.keyboardType = .emailAddress
        formTextFieldEmail.returnKeyType = .next
        formTextFieldEmail.textContentType = .emailAddress
    }
    
    private func configureOwnView() {
        title = "navigation.auth.signup".localized()
    }
    
    private func configurePasswordFormTextField() {
        formTextFieldPassword.returnKeyType = .next
        formTextFieldPassword.textContentType = .password
        
        formTextFieldPassword.enableSecureTextEntry()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoConfirmPasswordFormTextField()
        sinkIntoEmailFormTextField()
        sinkIntoKeyboardChanges()
        sinkIntoPasswordFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoConfirmPasswordFormTextField() {
        formTextFieldConfirmPassword.returnPublisher
            .sinkDiscardingValue { [weak textField = formTextFieldConfirmPassword] in
                textField?.resignFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldConfirmPassword.textPublisher
            .sink(receiveValue: viewModel.assignConfirmPassword(_:))
            .store(in: &cancellables)
    }
    
    private func sinkIntoEmailFormTextField() {
        formTextFieldEmail.returnPublisher
            .sinkDiscardingValue { [weak textField = formTextFieldPassword] in
                textField?.becomeFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldEmail.textPublisher
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
    
    private func sinkIntoPasswordFormTextField() {
        formTextFieldPassword.returnPublisher
            .sinkDiscardingValue { [weak textField = formTextFieldConfirmPassword] in
                textField?.becomeFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldPassword.textPublisher
            .sink(receiveValue: viewModel.assignPassword(_:))
            .store(in: &cancellables)
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
            .sink { [weak button = buttonRegister] in
                button?.isEnabled = $0
            }.store(in: &cancellables)
        
        viewModel.state
            .sink { [weak router = router] in
                router?.authenticationUpdateEventsSubject.send(.modelStateChanged($0))
            }.store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .first()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.router?.navigateToAdditionalInfoForm()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayFormErrors(_ formErrors: [AuthFormError]) {
        guard !formErrors.isEmpty else {
            return
        }
        
        for formError in formErrors {
            switch formError {
            case .confirmPassword:
                formTextFieldConfirmPassword.markError()
            case .email:
                formTextFieldEmail.markError()
            case .oldPassword:
                break
            case .password:
                formTextFieldPassword.markError()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func registerButtonTapped(_ sender: Any) {
        [formTextFieldConfirmPassword, formTextFieldEmail, formTextFieldPassword].forEach({
            $0?.clearErrorMarking()
        })
        
        view.endEditing(true)
        dismissMessage()
        
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SignUpWithEmailViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .authentication
    }
}

// MARK: Routable
extension SignUpWithEmailViewController: Routable {
    typealias RouterType = SignUpWithEmailRouter
    
    func assignRouter(_ router: SignUpWithEmailRouter) {
        self.router = router
    }
}

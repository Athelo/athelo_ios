//
//  AuthenticationLogInViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import CombineCocoa
import UIKit

final class LogInViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonForgotPassword: UIButton!
    @IBOutlet private weak var buttonLogIn: UIButton!
    @IBOutlet private weak var formTextFieldEmail: FormTextField!
    @IBOutlet private weak var formTextFieldPassword: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = LogInViewModel()
    private var router: LogInRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        formTextFieldEmail.text = "tester_ios@test.com"
        formTextFieldPassword.text = "test123"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        router?.authenticationUpdateEventsSubject.send(.legalLabelVisibilityChanged(true))
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentStackView()
        configureEmailFormTextField()
        configureForgotPasswordButton()
        configureOwnView()
        configurePasswordFormTextField()
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(16.0, after: formTextFieldPassword)
    }
    
    private func configureEmailFormTextField() {
        formTextFieldEmail.autocapitalizationType = .none
        formTextFieldEmail.autocorrectionType = .no
        formTextFieldEmail.keyboardType = .emailAddress
        formTextFieldEmail.returnKeyType = .next
        formTextFieldEmail.textContentType = .emailAddress
        
        formTextFieldEmail.delegate = self
    }
    
    private func configureForgotPasswordButton() {
        buttonForgotPassword.underlineTitle()
    }

    private func configureOwnView() {
        title = "navigation.auth.signin".localized()
    }
    
    private func configurePasswordFormTextField() {
        formTextFieldPassword.returnKeyType = .done
        formTextFieldPassword.textContentType = .password
        
        formTextFieldPassword.enableSecureTextEntry()
        
        formTextFieldPassword.delegate = self
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoFormTextFields()
        sinkIntoKeyboardChanges()
        sinkIntoViewModel()
    }
    
    private func sinkIntoFormTextFields() {
        formTextFieldEmail.currentTextPublisher
            .removeDuplicates()
            .sink(receiveValue: viewModel.assignEmail(_:))
            .store(in: &cancellables)
        
        formTextFieldPassword.currentTextPublisher
            .removeDuplicates()
            .sink(receiveValue: viewModel.assignPassword(_:))
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
            .sink { [weak button = buttonLogIn] in
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
        
        viewModel.state
            .toError(of: AuthenticationPingError.self)
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak router = router] in
                router?.navigateToAdditionalInfoForm()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayFormErrors(_ formErrors: [AuthFormError]) {
        guard !formErrors.isEmpty else {
            return
        }
        
        for formError in formErrors {
            switch formError {
            case .confirmPassword, .oldPassword:
                break
            case .email:
                formTextFieldEmail.markError()
            case .password:
                formTextFieldPassword.markError()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func forgotPasswordButtonTapped(_ sender: Any) {
        let additionalSafeAreaInsets = UIEdgeInsets(bottom: additionalSafeAreaInsets.bottom)
        
        router?.navigateToPasswordReset(with: .init(email: formTextFieldEmail.text), additionalSafeAreaInsets: additionalSafeAreaInsets)
    }
    
    @IBAction private func logInButtonTapped(_ sender: Any) {
        [formTextFieldEmail, formTextFieldPassword].forEach({
            $0?.clearErrorMarking()
        })
        
        view.endEditing(true)
        dismissMessage()
        
        viewModel.logIn()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension LogInViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .authentication
    }
}

// MARK: Routable
extension LogInViewController: Routable {
    typealias RouterType = LogInRouter
    
    func assignRouter(_ router: LogInRouter) {
        self.router = router
    }
}

// MARK: UITextFieldDelegate
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if formTextFieldEmail.containsInstanceOfTextField(textField) {
            formTextFieldPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

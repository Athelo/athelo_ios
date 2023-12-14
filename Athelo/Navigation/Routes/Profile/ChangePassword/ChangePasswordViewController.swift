//
//  ChangePasswordViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/06/2022.
//

import Combine
import UIKit

final class ChangePasswordViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonSaveNewPassword: UIButton!
    @IBOutlet private weak var formTextFieldConfirmPassword: FormTextField!
    @IBOutlet private weak var formTextFieldCurrentPassword: FormTextField!
    @IBOutlet private weak var formTextFieldNewPassword: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewWarning: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintScrollViewContentBottom: NSLayoutConstraint!
    @IBOutlet private weak var constraintStackViewContentBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = ChangePasswordViewModel()
    private var router: ChangePasswordRouter?
    
    private var cancellables: [AnyCancellable] = []

    // MARK: - Public API
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureConfirmPasswordFormTextField()
        configureContentStackView()
        configureCurrentPasswordFormTextField()
        configureNewPasswordFormTextField()
        configureOwnView()
    }
    
    private func configureConfirmPasswordFormTextField() {
        formTextFieldConfirmPassword.returnKeyType = .next
        formTextFieldConfirmPassword.textContentType = .password
        
        formTextFieldConfirmPassword.enableSecureTextEntry()
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(16.0, after: formTextFieldConfirmPassword)
    }
    
    private func configureCurrentPasswordFormTextField() {
        formTextFieldCurrentPassword.returnKeyType = .next
        formTextFieldCurrentPassword.textContentType = .password
        
        formTextFieldCurrentPassword.enableSecureTextEntry()
    }
    
    private func configureNewPasswordFormTextField() {
        formTextFieldNewPassword.returnKeyType = .next
        formTextFieldNewPassword.textContentType = .password
        
        formTextFieldNewPassword.enableSecureTextEntry()
    }
    
    private func configureOwnView() {
        self.title = "navigation.password.change".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoConfirmPasswordFormTextField()
        sinkIntoCurrentPasswordFormTextField()
        sinkIntoKeyboardChanges()
        sinkIntoNewPasswordFormTextField()
        sinkIntoVieWModel()
    }
    
    private func sinkIntoConfirmPasswordFormTextField() {
        formTextFieldConfirmPassword.currentTextPublisher
            .sink(receiveValue: viewModel.assignConfirmPassword(_:))
            .store(in: &cancellables)
        
        formTextFieldConfirmPassword.returnPublisher
            .sinkDiscardingValue { [weak formTextField = formTextFieldConfirmPassword] in
                formTextField?.resignFirstResponder()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoCurrentPasswordFormTextField() {
        formTextFieldCurrentPassword.currentTextPublisher
            .sink(receiveValue: viewModel.assignCurrentPassword(_:))
            .store(in: &cancellables)
        
        formTextFieldCurrentPassword.returnPublisher
            .sinkDiscardingValue { [weak formTextField = formTextFieldNewPassword] in
                formTextField?.becomeFirstResponder()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoNewPasswordFormTextField() {
        formTextFieldNewPassword.currentTextPublisher
            .sink(receiveValue: viewModel.assignPassword(_:))
            .store(in: &cancellables)
        
        formTextFieldNewPassword.returnPublisher
            .sinkDiscardingValue { [weak formTextField = formTextFieldConfirmPassword] in
                formTextField?.becomeFirstResponder()
            }.store(in: &cancellables)
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
    
    private func sinkIntoVieWModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$formErrors
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.displayFormErrors($0)
            }.store(in: &cancellables)
        
        viewModel.$isValid
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak button = buttonSaveNewPassword] in
                button?.isEnabled = $0
            }.store(in: &cancellables)
        
        viewModel.$successMessage
            .compactMap({ $0 })
            .filter({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.displayMessage($0, type: .success)
            }.store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.resetFormData()
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
                break
            case .oldPassword:
                formTextFieldCurrentPassword.markError()
            case .password:
                formTextFieldNewPassword.markError()
            }
        }
    }
    
    private func resetFormData() {
        [formTextFieldConfirmPassword,
         formTextFieldCurrentPassword,
         formTextFieldNewPassword].forEach({
            $0?.text = nil
        })
    }
    
    @IBAction private func saveNewPasswordButtonTapped(_ sender: Any) {
        [formTextFieldConfirmPassword, formTextFieldCurrentPassword, formTextFieldNewPassword].forEach({
            $0?.clearErrorMarking()
        })
        
        view.endEditing(true)
        dismissMessage()
        
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension ChangePasswordViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .profile
    }
}

// MARK: Routable
extension ChangePasswordViewController: Routable {
    typealias RouterType = ChangePasswordRouter
    
    func assignRouter(_ router: ChangePasswordRouter) {
        self.router = router
    }
}

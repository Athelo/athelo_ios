//
//  AuthenticationSignUpViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Combine
import UIKit

final class SignUpViewController: BaseViewController {
    // MARK: - Constants
    private enum Mode {
        case logIn
        case signUp
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var buttonApple: StyledButton!
    @IBOutlet private weak var buttonEmail: UIButton!
    @IBOutlet private weak var buttonFacebook: UIButton!
    @IBOutlet private weak var buttonGoogle: UIButton!
    @IBOutlet private weak var buttonLogIn: UIButton!
    @IBOutlet private weak var buttonSignUp: UIButton!
    @IBOutlet private weak var buttonTwitter: UIButton!
    @IBOutlet private weak var stackViewTabButtons: UIStackView!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewSelection: UIView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintViewSelectionCenterX: NSLayoutConstraint!
    
    // MARK: - Properties
    private var router: SignUpRouter?
    
    private let contentTopOffset = CurrentValueSubject<CGFloat?, Never>(nil)
    private let currentMode = CurrentValueSubject<Mode, Never>(.signUp)
    
    private var cancellables: [AnyCancellable] = []
    private var thirdPartyCancellable: AnyCancellable? = nil
    
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
        configureOwnView()
        configureSelectionView()
    }
    
    private func configureOwnView() {
        if parent != nil {
            view.backgroundColor = .clear
        }
    }
    
    private func configureSelectionView() {
        viewSelection.layer.cornerRadius = 2.0
        viewSelection.layer.masksToBounds = true
        
        updateSelectionViewPosition(animated: false)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        currentMode
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.updateStateButtons()
            }.store(in: &cancellables)
        
        currentMode
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.updateSelectionViewPosition()
                self?.updateOptionButtons()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func signInWithThirdPartyPlatform(_ platform: ThirdPartyAuthenticationPlatform) {
        guard thirdPartyCancellable == nil else {
            return
        }
        
        router?.authenticationUpdateEventsSubject.send(.modelStateChanged(.loading))
        
        thirdPartyCancellable?.cancel()
        thirdPartyCancellable = IdentityUtility.signInWithThirdPartyPlatform(platform)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.router?.authenticationUpdateEventsSubject.send(.modelStateChanged(.error(error: error)))
                    if error is AuthenticationPingError {
                        self?.router?.navigateToAdditionalInfoForm()
                    }
                }
                
                self?.thirdPartyCancellable?.cancel()
                self?.thirdPartyCancellable = nil
            }, receiveValue: { [weak self] _ in
                self?.router?.authenticationUpdateEventsSubject.send(.modelStateChanged(.loaded))
                self?.router?.navigateOnSuccessfulAuthentication()
            })
    }
    
    private func updateOptionButtons() {
        var suffix: String
        
        switch currentMode.value {
        case .logIn:
            suffix = "signin"
        case .signUp:
            suffix = "signup"
        }
        
        buttonApple.setTitle("auth.apple.\(suffix)".localized(), for: .normal)
        buttonEmail.setTitle("auth.email.\(suffix)".localized(), for: .normal)
        buttonFacebook.setTitle("auth.facebook.\(suffix)".localized(), for: .normal)
        buttonGoogle.setTitle("auth.google.\(suffix)".localized(), for: .normal)
        buttonTwitter.setTitle("auth.twitter.\(suffix)".localized(), for: .normal)
    }
    
    private func updateStateButtons() {
        let logInButtonColor: UIColor = currentMode.value == .logIn ? .withStyle(.gray) : .withStyle(.lightGray)
        let signUpButtonColor: UIColor = currentMode.value == .signUp ? .withStyle(.gray) : .withStyle(.lightGray)
        
        UIView.transition(with: stackViewTabButtons, duration: 0.2, options: [.beginFromCurrentState, .transitionCrossDissolve]) { [weak self] in
            self?.buttonLogIn.setTitleColor(logInButtonColor, for: .normal)
            self?.buttonSignUp.setTitleColor(signUpButtonColor, for: .normal)
        }
    }
    
    private func updateSelectionViewPosition(animated: Bool = true) {
        guard let actionButtonWidth = stackViewTabButtons.subviews.first?.bounds.width else {
            return
        }
        
        var targetOffset = actionButtonWidth / 2.0
        switch currentMode.value {
        case .logIn:
            break
        case .signUp:
            targetOffset *= -1.0
        }
        
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.beginFromCurrentState]) { [weak self] in
                self?.constraintViewSelectionCenterX.constant = targetOffset
                self?.view.layoutIfNeeded()
            }
        } else {
            UIView.performWithoutAnimation { [weak self] in
                self?.constraintViewSelectionCenterX.constant = targetOffset
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func appleButtonTapped(_ sender: Any) {
        signInWithThirdPartyPlatform(.apple)
    }
    
    @IBAction private func emailButtonTapped(_ sender: Any) {
        switch currentMode.value {
        case .logIn:
            router?.navigateToEmailLogin(additionalSafeAreaInsets: additionalSafeAreaInsets)
        case .signUp:
            router?.navigateToEmailSignup(additionalSafeAreaInsets: additionalSafeAreaInsets)
        }
    }
    
    @IBAction private func facebookButtonTapped(_ sender: Any) {
        displayMessage("message.comingsoon".localized())
    }
    
    @IBAction private func googleButtonTapped(_ sender: Any) {
        signInWithThirdPartyPlatform(.google)
    }
    
    @IBAction private func logInButtonTapped(_ sender: Any) {
        guard currentMode.value != .logIn else {
            return
        }
        
        currentMode.send(.logIn)
    }
    
    @IBAction private func signUpButtonTapped(_ sender: Any) {
        guard currentMode.value != .signUp else {
            return
        }
        
        currentMode.send(.signUp)
    }
    
    @IBAction private func twitterButtonTapped(_ sender: Any) {
        displayMessage("message.comingsoon".localized())
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension SignUpViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .authentication
    }
}

// MARK: Routable
extension SignUpViewController: Routable {
    typealias RouterType = SignUpRouter
    
    func assignRouter(_ router: SignUpRouter) {
        self.router = router
    }
}

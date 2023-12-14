//
//  InviteCaregiverViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/03/2023.
//

import Combine
import UIKit

final class InviteCaregiverViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonInviteCaregiver: UIButton!
    @IBOutlet private weak var formTextFieldEmailAddress: FormTextField!
    @IBOutlet private weak var formTextFieldRelation: FormTextField!
    @IBOutlet private weak var formTextFieldUserName: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    private weak var relationTypeInputView: ListInputView?
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintContentScrollViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = InviteCaregiverViewModel()
    private var router: InviteCaregiverRouter?
    
    private var relationTypeDismissalGestureRecognizer: UITapGestureRecognizer?
    
    private var cancellables: [AnyCancellable] = []
    private var relationTypeInputCancellable: AnyCancellable?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureEmailAddressFormTextField()
        configureOwnView()
        configureRelationFormTextField()
        configureUserNameFormTextField()
    }
    
    private func configureEmailAddressFormTextField() {
        formTextFieldEmailAddress.autocapitalizationType = .none
        formTextFieldEmailAddress.autocorrectionType = .no
        formTextFieldEmailAddress.returnKeyType = .next
        formTextFieldEmailAddress.textContentType = .emailAddress
        
        formTextFieldEmailAddress.delegate = self
    }
    
    private func configureOwnView() {
        title = "navigation.role.patient".localized()
    }
    
    private func configureRelationFormTextField() {
        formTextFieldRelation.delegate = self
    }
    
    private func configureUserNameFormTextField() {
        formTextFieldUserName.autocapitalizationType = .words
        formTextFieldUserName.autocorrectionType = .no
        formTextFieldUserName.returnKeyType = .next
        formTextFieldUserName.textContentType = .name
        
        formTextFieldUserName.delegate = self
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoEmailAddressFormTextField()
        sinkIntoKeyboardChanges()
        sinkIntoNameFormTextField()
        sinkIntoRelationFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoEmailAddressFormTextField() {
        formTextFieldEmailAddress.returnPublisher
            .sinkDiscardingValue { [weak self] in
                self?.formTextFieldRelation.becomeFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldEmailAddress.textPublisher
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewModel.assignEmail($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] in
                guard let self else {
                    return
                }
                
                self.adjustBottomOffset(using: self.constraintContentScrollViewBottom, keyboardChangeData: $0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoNameFormTextField() {
        formTextFieldUserName.returnPublisher
            .sinkDiscardingValue { [weak self] in
                self?.formTextFieldEmailAddress.becomeFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldUserName.textPublisher
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewModel.assignName($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoRelationFormTextField() {
        formTextFieldRelation.displayIcon(.verticalChevron)
            .sink { [weak self] in
                if self?.formTextFieldRelation == nil {
                    self?.displayRelationTypeInputView()
                } else {
                    self?.hideRelationTypeInputView()
                }
                
                self?.view.endEditing(true)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$isValid
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: buttonInviteCaregiver)
            .store(in: &cancellables)
        
        viewModel.$relationType
            .map({ $0?.name })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: formTextFieldRelation)
            .store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.formTextFieldEmailAddress.text = nil
                self?.formTextFieldRelation.text = nil
                self?.formTextFieldUserName.text = nil
                
                self?.router?.inviteCaregiverUpdateEventsSubject.send(.invitationSent)
            }.store(in: &cancellables)
        
        viewModel.successMessagePublisher
            .map({ InfoMessageData(text: $0, type: .success) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.router?.navigateAfterSuccess()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func displayRelationTypeInputView() {
        guard relationTypeInputView == nil else {
            return
        }
        
        let inputView = ListInputView.instantiate()
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.alpha = 0.0
        
        scrollViewContent.addSubview(inputView)
        relationTypeInputView = inputView
        
        adjustFrameOfFormInputView(inputView, inRelationTo: formTextFieldRelation, inside: stackViewContent, of: scrollViewContent, estimatedComponentHeight: inputView.maximumExpectedContainerHeight)
        
        UIView.animate(withDuration: 0.3) {
            inputView.alpha = 1.0
        }
        
        weak var weakSelf = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: weakSelf, action: #selector(handleRelationTypeInputViewDismissalGestureRecognizerRecognition(_:)))
        tapGestureRecognizer.delegate = self
        
        if let relationTypeDismissalGestureRecognizer {
            view.removeGestureRecognizer(relationTypeDismissalGestureRecognizer)
        }
        view.addGestureRecognizer(tapGestureRecognizer)
        
        relationTypeDismissalGestureRecognizer = tapGestureRecognizer
        
        inputView.assignAndFireItemsPublisher(viewModel.relationTypesPublisher(), preselecting: viewModel.relationType)
        
        relationTypeInputCancellable?.cancel()
        relationTypeInputCancellable = inputView.selectedItemPublisher
            .compactMap({ $0 as? CaregiverRelationLabelConstant })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.assignRelationType($0)
                
                self?.hideRelationTypeInputView()
                self?.view.endEditing(true)
            }
        
        view.endEditing(true)
        
        formTextFieldRelation.activateIcon(.verticalChevron)
    }
    
    private func hideRelationTypeInputView() {
        guard relationTypeInputView != nil else {
            return
        }
        
        if let relationTypeDismissalGestureRecognizer {
            view.removeGestureRecognizer(relationTypeDismissalGestureRecognizer)
        }
        
        formTextFieldRelation.deactivateIcon(.verticalChevron)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.relationTypeInputView?.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                self?.relationTypeInputView?.removeFromSuperview()
                self?.relationTypeInputView = nil
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func handleRelationTypeInputViewDismissalGestureRecognizerRecognition(_ sender: Any) {
        guard (sender as? UITapGestureRecognizer) == relationTypeDismissalGestureRecognizer else {
            return
        }
        
        hideRelationTypeInputView()
    }
    
    @IBAction private func handleInviteCaregiverButtonTap(_ sender: Any) {
        view.endEditing(true)
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension InviteCaregiverViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .role
    }
}

// MARK: Routable
extension InviteCaregiverViewController: Routable {
    func assignRouter(_ router: InviteCaregiverRouter) {
        self.router = router
    }
}

// MARK: UIGestureRecognizerDelegate
extension InviteCaregiverViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let relationTypeInputView,
           relationTypeInputView.bounds.contains(touch.location(in: relationTypeInputView)) {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UITextFieldDelegate
extension InviteCaregiverViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        !formTextFieldRelation.containsInstanceOfTextField(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if formTextFieldRelation.containsInstanceOfTextField(textField) {
            if relationTypeInputView == nil {
                displayRelationTypeInputView()
            }
            
            view.endEditing(true)
            
            return false
        }
        
        return true
    }
}

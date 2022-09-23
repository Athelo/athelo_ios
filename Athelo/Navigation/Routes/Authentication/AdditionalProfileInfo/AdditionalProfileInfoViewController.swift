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
    @IBOutlet private weak var formTextFieldWhatDescribesYou: FormTextField!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewContent: UIStackView!
    
    private weak var userTypeInputView: ListInputView?
    
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
        configureDescriptionFormTextField()
        configureOwnView()
        configureNameFormTextField()
    }
    
    private func configureDescriptionFormTextField() {
        formTextFieldWhatDescribesYou.delegate = self
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
        sinkIntoDescriptionFormTextField()
        sinkIntoKeyboardChanges()
        sinkIntoNameFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoDescriptionFormTextField() {
        let iconTapPublisher = formTextFieldWhatDescribesYou.displayIcon(.verticalChevron)
        
        iconTapPublisher
            .sink { [weak self] in
                if self?.userTypeInputView == nil {
                    self?.formTextFieldWhatDescribesYou.activateIcon(.verticalChevron)
                    self?.appendCustomUserTypeInputView()
                } else {
                    self?.formTextFieldWhatDescribesYou.deactivateIcon(.verticalChevron)
                    self?.hideUserTypeInputView(nil)
                    
                    self?.view.endEditing(true)
                }
            }.store(in: &cancellables)
    }
    
    private func sinkIntoNameFormTextField() {
        formTextFieldName.returnPublisher
            .sink { [weak self] in
                self?.formTextFieldWhatDescribesYou.becomeFirstResponder()
            }.store(in: &cancellables)
        
        formTextFieldName.textPublisher
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
            .sinkDiscardingValue { [weak self] in
                self?.router?.navigateToSync()
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
    private func appendCustomUserTypeInputView() {
        guard userTypeInputView == nil else {
            return
        }
        
        let inputView = ListInputView.instantiate()
        
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.alpha = 0.0
        
        scrollViewContent.addSubview(inputView)
        userTypeInputView = inputView
        
        let textFieldWindowFrame = stackViewContent.convert(formTextFieldWhatDescribesYou.frame, to: nil)
        let textFieldScrollViewFrame = stackViewContent.convert(formTextFieldWhatDescribesYou.frame, to: scrollViewContent)
        
        var shouldAppendInputBelowTextField: Bool = true
        if textFieldWindowFrame.maxY + 8.0 + inputView.maximumExpectedContainerHeight > AppRouter.current.window.bounds.maxY {
            shouldAppendInputBelowTextField = false
        }
        
        if shouldAppendInputBelowTextField {
            inputView.frame = .init(origin: .init(x: textFieldScrollViewFrame.minX, y: textFieldScrollViewFrame.maxY + 16.0), size: .zero)
        } else {
            // Estimated for now, might want to make smarter assumptions about initial inputView frame.
            inputView.frame = .init(origin: .init(x: textFieldScrollViewFrame.minX, y: textFieldScrollViewFrame.minY - 16.0), size: .zero)
        }
        
        var activatedConstraints: [NSLayoutConstraint] = []
        activatedConstraints.append(contentsOf: [
            inputView.widthAnchor.constraint(equalTo: formTextFieldWhatDescribesYou.widthAnchor),
            inputView.centerXAnchor.constraint(equalTo: formTextFieldWhatDescribesYou.centerXAnchor)
        ])
        
        if shouldAppendInputBelowTextField {
            activatedConstraints.append(inputView.topAnchor.constraint(equalTo: formTextFieldWhatDescribesYou.bottomAnchor, constant: 8.0))
        } else {
            activatedConstraints.append(inputView.bottomAnchor.constraint(equalTo: formTextFieldWhatDescribesYou.topAnchor, constant: 8.0))
        }
        
        NSLayoutConstraint.activate(activatedConstraints)
        
        UIView.animate(withDuration: 0.3) {
            inputView.alpha = 1.0
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOwnViewTapGestureRecognizer))
        tapGestureRecognizer.delegate = self
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
        inputView.assignAndFireItemsPublisher(viewModel.userTypesPublisher(), preselecting: viewModel.selectedUserType)
        
        userTypeInputCancellable?.cancel()
        userTypeInputCancellable = inputView.selectedItemPublisher
            .compactMap({ $0 as? UserTypeConstant })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.formTextFieldWhatDescribesYou.text = value.name
                self?.viewModel.assignUserType(value)
                
                self?.hideUserTypeInputView(nil)
                self?.view.endEditing(true)
                
                self?.formTextFieldWhatDescribesYou.deactivateIcon(.verticalChevron)
            }
        
        if formTextFieldName.isFirstResponder {
            formTextFieldName.resignFirstResponder()
        }
    }
    
    @IBAction private func handleOwnViewTapGestureRecognizer(_ sender: Any?) {
        guard let gestureRecognizer = sender as? UITapGestureRecognizer,
              gestureRecognizer.view === self.view else {
            return
        }
        
        hideUserTypeInputView(sender)
        
        formTextFieldWhatDescribesYou.deactivateIcon(.verticalChevron)
    }
    
    @IBAction private func hideUserTypeInputView(_ sender: Any?) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.userTypeInputView?.alpha = 0.0
        } completion: { [weak self] completed in
            if completed {
                self?.userTypeInputView?.removeFromSuperview()
                self?.userTypeInputView = nil
            }
        }
        
        let gestureRecognizers = view.gestureRecognizers
        gestureRecognizers?.forEach({
            view.removeGestureRecognizer($0)
        })
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        [formTextFieldName, formTextFieldWhatDescribesYou].forEach({
            $0?.clearErrorMarking()
        })
        
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

// MARK: UIGestureRecognizerDelegate
extension AdditionalProfileInfoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let customInputView = userTypeInputView,
           customInputView.bounds.contains(touch.location(in: customInputView)) {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: UITextFieldDelegate
extension AdditionalProfileInfoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        !formTextFieldWhatDescribesYou.containsInstanceOfTextField(textField)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if formTextFieldWhatDescribesYou.containsInstanceOfTextField(textField) {
            if userTypeInputView == nil {
                formTextFieldWhatDescribesYou.activateIcon(.verticalChevron)
                appendCustomUserTypeInputView()
            }
            
            view.endEditing(true)
            
            return false
        }
        
        return true
    }
}

//
//  InvitationCodeViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/09/2022.
//

import Combine
import UIKit

final class InvitationCodeViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonMissingCode: UIButton!
    @IBOutlet private weak var buttonNext: UIButton!
    @IBOutlet private weak var stackViewContent: UIStackView!
    @IBOutlet private weak var stackViewCodeContainer: UIStackView!
    @IBOutlet private weak var textFieldFirstDigit: BaseStyledTextField!
    @IBOutlet private weak var textFieldSecondDigit: BaseStyledTextField!
    @IBOutlet private weak var textFieldThirdDigit: BaseStyledTextField!
    @IBOutlet private weak var textFieldFourthDigit: BaseStyledTextField!
    @IBOutlet private weak var textFieldFifthDigit: BaseStyledTextField!
    @IBOutlet private weak var textFieldSixthDigit: BaseStyledTextField!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintNextButtonBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = InvitationCodeViewModel()
    private var router: InvitationCodeRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContentStackView()
        configureMissingCodeButton()
        configureOwnView()
        configureTextFields()
    }
    
    private func configureContentStackView() {
        stackViewContent.setCustomSpacing(24.0, after: stackViewCodeContainer)
    }
    
    private func configureMissingCodeButton() {
        buttonMissingCode.underlineTitle()
    }
    
    private func configureOwnView() {
        title = "navigation.auth.invitationcode".localized()
    }
    
    private func configureTextFields() {
        [textFieldFirstDigit, textFieldSecondDigit, textFieldThirdDigit, textFieldFourthDigit, textFieldFifthDigit, textFieldSixthDigit].forEach {
            $0?.keyboardType = .numberPad
            $0?.delegate = self
        }
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoKeyboardChanges()
        sinkIntoTextFields()
        sinkIntoViewModel()
    }
    
    private func sinkIntoKeyboardChanges() {
        keyboardInfoPublisher
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.adjustBottomOffset(using: self.constraintNextButtonBottom, keyboardChangeData: value, additionalOffset: 16.0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoTextFields() {
        [textFieldFirstDigit, textFieldSecondDigit, textFieldThirdDigit, textFieldFourthDigit, textFieldFifthDigit, textFieldSixthDigit].enumerated().forEach({ (index, textField) in
            textField?.deleteBackwardPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] textField in
                    textField.text = nil
                    textField.sendActions(for: .valueChanged)

                    self?.selectPreviousTextField(relativeTo: textField)
                }
                .store(in: &cancellables)
            
            textField?.textPublisher
                .map({ $0?.count == 1 ? $0 : nil })
                .removeDuplicates()
                .sink { [weak self] value in
                    self?.viewModel.updateDigit(value, at: index)
                }.store(in: &cancellables)
        })
        
        let firstDigitPublisher = textFieldFirstDigit.textPublisher.validCodeInputPublisher()
        let secondDigitPublisher = textFieldSecondDigit.textPublisher.validCodeInputPublisher()
        let thirdDigitPublisher = textFieldThirdDigit.textPublisher.validCodeInputPublisher()
        let fourthDigitPublisher = textFieldFourthDigit.textPublisher.validCodeInputPublisher()
        let fifthDigitPublisher = textFieldFifthDigit.textPublisher.validCodeInputPublisher()
        let sixthDigitPublisher = textFieldSixthDigit.textPublisher.validCodeInputPublisher()
        
        let validSignTextFieldPublishers: [AnyPublisher<UITextField, Never>] = [
            firstDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldFirstDigit }).eraseToAnyPublisher(),
            secondDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldSecondDigit }).eraseToAnyPublisher(),
            thirdDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldThirdDigit }).eraseToAnyPublisher(),
            fourthDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldFourthDigit }).eraseToAnyPublisher(),
            fifthDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldFifthDigit }).eraseToAnyPublisher(),
            sixthDigitPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldSixthDigit }).eraseToAnyPublisher()
        ]
        
        validSignTextFieldPublishers.forEach {
            $0.receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.selectNextTextField(relativeTo: $0)
                }.store(in: &cancellables)
        }
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$isValid
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: buttonNext)
            .store(in: &cancellables)
        
        viewModel.state
            .filter({ $0.notifiesAboutDataUpdate })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.clearCode()
            }.store(in: &cancellables)
        
        viewModel.state
            .filter({ $0 == .loaded })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.router?.invitationCodeUpdateEventsSubject.send(.codeAccepted)
            }.store(in: &cancellables)
        
        viewModel.successMessagePublisher
            .map({ InfoMessageData(text: $0, type: .success) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.router?.navigateAfterSuccess()
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func clearCode() {
        [textFieldFirstDigit, textFieldSecondDigit, textFieldThirdDigit, textFieldFourthDigit, textFieldFifthDigit, textFieldSixthDigit].forEach({
            $0?.text = nil
            $0?.sendActions(for: .valueChanged)
        })
    }
    
    private func prefillCode(_ code: String) {
        guard code.count == 6,
              CharacterSet.whitespacesAndNewlines.isDisjoint(with: CharacterSet(charactersIn: code)),
              CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: code)) else {
            return
        }

        view.endEditing(true)

        code.enumerated().forEach({ (index, element) in
            switch index {
            case 0:
                textFieldFirstDigit.text = String(element)
                textFieldFirstDigit.sendActions(for: .valueChanged)
            case 1:
                textFieldSecondDigit.text = String(element)
                textFieldSecondDigit.sendActions(for: .valueChanged)
            case 2:
                textFieldThirdDigit.text = String(element)
                textFieldThirdDigit.sendActions(for: .valueChanged)
            case 3:
                textFieldFourthDigit.text = String(element)
                textFieldFourthDigit.sendActions(for: .valueChanged)
            case 4:
                textFieldFifthDigit.text = String(element)
                textFieldFifthDigit.sendActions(for: .valueChanged)
            case 5:
                textFieldSixthDigit.text = String(element)
                textFieldSixthDigit.sendActions(for: .valueChanged)
            default:
                break
            }
        })
    }
    
    private func selectNextTextField(relativeTo sourceTextField: UITextField) {
        switch sourceTextField {
        case textFieldFirstDigit:
            textFieldSecondDigit.becomeFirstResponder()
        case textFieldSecondDigit:
            textFieldThirdDigit.becomeFirstResponder()
        case textFieldThirdDigit:
            textFieldFourthDigit.becomeFirstResponder()
        case textFieldFourthDigit:
            textFieldFifthDigit.becomeFirstResponder()
        case textFieldFifthDigit:
            textFieldSixthDigit.becomeFirstResponder()
        case textFieldSixthDigit:
            textFieldSixthDigit.resignFirstResponder()
        default:
            break
        }
    }
    
    private func selectPreviousTextField(relativeTo sourceTextField: UITextField) {
        switch sourceTextField {
        case textFieldFirstDigit:
            break
        case textFieldSecondDigit:
            textFieldFirstDigit.becomeFirstResponder()
        case textFieldThirdDigit:
            textFieldSecondDigit.becomeFirstResponder()
        case textFieldFourthDigit:
            textFieldThirdDigit.becomeFirstResponder()
        case textFieldFifthDigit:
            textFieldFourthDigit.becomeFirstResponder()
        case textFieldSixthDigit:
            textFieldFifthDigit.becomeFirstResponder()
        default:
            break
        }
    }
    
    // MARK: - Actions
    @IBAction private func missingCodeButtonTapped(_ sender: Any) {
        /* ... */
    }
    
    @IBAction private func nextButtonTapped(_ sender: Any) {
        viewModel.sendRequest()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension InvitationCodeViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .role
    }
}

// MARK: Routable
extension InvitationCodeViewController: Routable {
    func assignRouter(_ router: InvitationCodeRouter) {
        self.router = router
    }
}

// MARK: UITextFieldDelegate
extension InvitationCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            guard CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }

            guard CharacterSet.whitespacesAndNewlines.isDisjoint(with: CharacterSet(charactersIn: string)) else {
                if CharacterSet.newlines.isSuperset(of: CharacterSet(charactersIn: string)) {
                    textField.resignFirstResponder()
                }

                return false
            }
        }

        // Handles valid code copy-pasting.
        if string.count == 6 {
            prefillCode(string)
            return false
        }

        if textField.text == nil || textField.text?.isEmpty == true {
            // Fallback `deleteBackward` event handler.
            if string.isEmpty {
                selectPreviousTextField(relativeTo: textField)

                return false
            // New sign event handler.
            } else if string.count == 1 {
                return true
            }
        } else if textField.text?.count == 1 {
            // Removing sign handler, pushed into `deleteBackward` event by system.
            if string.isEmpty {
                return true
            // Sign replacing event.
            } else if string.count == 1 {
                textField.text = string
                textField.sendActions(for: .valueChanged)

                selectNextTextField(relativeTo: textField)

                return false
            }
        }

        return false
    }
}

// MARK: - Helper extensions
private extension Publisher where Output == String? {
    func validCodeInputPublisher() -> AnyPublisher<Bool, Failure> {
        map({ $0?.count == 1 }).removeDuplicates().eraseToAnyPublisher()
    }
}

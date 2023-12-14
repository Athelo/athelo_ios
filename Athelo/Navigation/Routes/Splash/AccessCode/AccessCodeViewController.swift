//
//  AccessCodeViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Combine
import UIKit

final class AccessCodeViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var textFieldFirstCodeNumber: BaseStyledTextField!
    @IBOutlet private weak var textFieldFourthCodeNumber: BaseStyledTextField!
    @IBOutlet private weak var textFieldSecondCodeNumber: BaseStyledTextField!
    @IBOutlet private weak var textFieldThirdCodeNumber: BaseStyledTextField!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintCodeInputContainerViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = AccessCodeViewModel()
    private var router: AccessCodeRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureTextFields()
    }
    
    private func configureTextFields() {
        [textFieldFirstCodeNumber, textFieldSecondCodeNumber, textFieldThirdCodeNumber, textFieldFourthCodeNumber].forEach {
            $0?.keyboardType = .numberPad
            $0?.delegate = self
        }
    }
    
    // MARK: - Sinks
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
                
                self.adjustBottomOffset(using: self.constraintCodeInputContainerViewBottom, keyboardChangeData: value, additionalOffset: 16.0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoTextFields() {
        [textFieldFirstCodeNumber, textFieldSecondCodeNumber, textFieldThirdCodeNumber, textFieldFourthCodeNumber].forEach({
            $0?.deleteBackwardPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] textField in
                    textField.text = nil
                    textField.sendActions(for: .valueChanged)

                    self?.selectPreviousTextField(relativeTo: textField)
                }
                .store(in: &cancellables)
        })
        
        let firstCodeNumberPublisher = textFieldFirstCodeNumber.textPublisher.validCodeInputPublisher()
        let secondCodeNumberPublisher = textFieldSecondCodeNumber.textPublisher.validCodeInputPublisher()
        let thirdCodeNumberPublisher = textFieldThirdCodeNumber.textPublisher.validCodeInputPublisher()
        let fourthCodeNumberPublisher = textFieldFourthCodeNumber.textPublisher.validCodeInputPublisher()

        let validSignTextFieldPublishers: [AnyPublisher<UITextField, Never>] = [
            firstCodeNumberPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldFirstCodeNumber }).eraseToAnyPublisher(),
            secondCodeNumberPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldSecondCodeNumber }).eraseToAnyPublisher(),
            thirdCodeNumberPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldThirdCodeNumber }).eraseToAnyPublisher(),
            fourthCodeNumberPublisher.filter({ $0 }).compactMap({ [weak self] _ in self?.textFieldFourthCodeNumber }).eraseToAnyPublisher()
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
        
        viewModel.$route
            .compactMap({ $0 })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.router?.resolveRoute($0)
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private func checkCode() {
        let code: String =
            (textFieldFirstCodeNumber.text ?? "")
            + (textFieldSecondCodeNumber.text ?? "")
            + (textFieldThirdCodeNumber.text ?? "")
            + (textFieldFourthCodeNumber.text ?? "")
        
        viewModel.checkCode(code)
        
        [textFieldFirstCodeNumber, textFieldSecondCodeNumber, textFieldThirdCodeNumber, textFieldFourthCodeNumber].forEach({
            $0?.text = nil
            $0?.sendActions(for: .valueChanged)
        })
    }
    
    private func prefillCode(_ code: String) {
        guard code.count == 4,
              CharacterSet.whitespacesAndNewlines.isDisjoint(with: CharacterSet(charactersIn: code)),
              CharacterSet.alphanumerics.isSuperset(of: CharacterSet(charactersIn: code)) else {
            return
        }

        view.endEditing(true)

        code.enumerated().forEach({ (index, element) in
            switch index {
            case 0:
                textFieldFirstCodeNumber.text = String(element)
                textFieldFirstCodeNumber.sendActions(for: .valueChanged)
            case 1:
                textFieldSecondCodeNumber.text = String(element)
                textFieldSecondCodeNumber.sendActions(for: .valueChanged)
            case 2:
                textFieldThirdCodeNumber.text = String(element)
                textFieldThirdCodeNumber.sendActions(for: .valueChanged)
            case 3:
                textFieldFourthCodeNumber.text = String(element)
                textFieldFourthCodeNumber.sendActions(for: .valueChanged)
            default:
                break
            }
        })
        
        checkCode()
    }
    
    private func selectNextTextField(relativeTo sourceTextField: UITextField) {
        switch sourceTextField {
        case textFieldFirstCodeNumber:
            textFieldSecondCodeNumber.becomeFirstResponder()
        case textFieldSecondCodeNumber:
            textFieldThirdCodeNumber.becomeFirstResponder()
        case textFieldThirdCodeNumber:
            textFieldFourthCodeNumber.becomeFirstResponder()
        case textFieldFourthCodeNumber:
            textFieldFourthCodeNumber.resignFirstResponder()
            checkCode()
        default:
            break
        }
    }
    
    private func selectPreviousTextField(relativeTo sourceTextField: UITextField) {
        switch sourceTextField {
        case textFieldFirstCodeNumber:
            break
        case textFieldSecondCodeNumber:
            textFieldFirstCodeNumber.becomeFirstResponder()
        case textFieldThirdCodeNumber:
            textFieldSecondCodeNumber.becomeFirstResponder()
        case textFieldFourthCodeNumber:
            textFieldThirdCodeNumber.becomeFirstResponder()
        default:
            break
        }
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension AccessCodeViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .splash
    }
}

// MARK: Routable
extension AccessCodeViewController: Routable {
    func assignRouter(_ router: AccessCodeRouter) {
        self.router = router
    }
}

// MARK: UITextFieldDelegate
extension AccessCodeViewController: UITextFieldDelegate {
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
        if string.count == 4 {
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

//
//  AddContactViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/09/2022.
//

import Combine
import CombineCocoa
import UIKit

final class AddContactViewController: KeyboardListeningViewController {
    // MARK: - Outlets
    @IBOutlet private weak var buttonFind: UIButton!
    @IBOutlet private weak var formTextFieldPhoneNumber: FormTextField!
    @IBOutlet private weak var formTextFieldRelation: FormTextField!
    @IBOutlet private weak var formTextFieldUserName: FormTextField!
    @IBOutlet private weak var labelHeader: UILabel!
    @IBOutlet private weak var scrollViewContent: UIScrollView!
    @IBOutlet private weak var stackViewForm: UIStackView!
    
    // MARK: - Constraints
    @IBOutlet private weak var constraintContentScrollViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    private let viewModel = AddContactViewModel()
    private var router: AddContactRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
    }
    
    // MARK: - Configuration
    private func configure() {
        configurePhoneNumberFormTextField()
    }
    
    private func configurePhoneNumberFormTextField() {
        formTextFieldPhoneNumber.keyboardType = .phonePad
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoPhoneNumberFormTextField()
        sinkIntoUserNameFormTextField()
        sinkIntoViewModel()
    }
    
    private func sinkIntoPhoneNumberFormTextField() {
        formTextFieldPhoneNumber.textPublisher
            .sink(receiveValue: viewModel.assignPhoneNumber(_:))
            .store(in: &cancellables)
        
        formTextFieldPhoneNumber.returnPublisher
            .sink { [weak self] in
                self?.formTextFieldRelation.becomeFirstResponder()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoUserNameFormTextField() {
        formTextFieldUserName.textPublisher
            .sink(receiveValue: viewModel.assignUserName(_:))
            .store(in: &cancellables)
        
        formTextFieldUserName.returnPublisher
            .sink { [weak self] in
                self?.formTextFieldPhoneNumber.becomeFirstResponder()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
        
        viewModel.$isValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.buttonFind.alpha = $0 ? 1.0 : 0.5
                self?.buttonFind.isEnabled = $0
            }.store(in: &cancellables)
    }
    
    // MARK: - Actions
    @IBAction private func findButtonTapped(_ sender: Any) {
        
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension AddContactViewController: Configurable {
    func assignConfigurationData(_ configurationData: UserRole) {
        viewModel.assignUserRole(configurationData)
    }
}

// MARK: Navigable
extension AddContactViewController: Navigable {
    static var storyboardScene: StoryboardScene{
        .profile
    }
}

// MARK: Routable
extension AddContactViewController: Routable {
    func assignRouter(_ router: AddContactRouter) {
        self.router = router
    }
}

//
//  PatientRoleViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Combine
import UIKit

final class PatientRoleViewController: BaseViewController {
    // MARK: - Outlets
    private var patientRoleScreen: PatientRoleScreen?
    
    // MARK: - Properties
    private let viewModel = PatientRoleViewModel()
    private var router: PatientRoleRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.updateCaregiverList()
    }
    
    // MARK: - Configure
    private func configure() {
        configureContentView()
        configureOwnView()
    }
    
    private func configureContentView() {
        if patientRoleScreen != nil {
            return
        }
        
        let patientRoleScreen = PatientRoleScreen(
            model: viewModel.model,
            onAddACaregiver: { [weak self] in
                self?.router?.navigateToCaregiverInvitationForm()
            },
            onContinue: { [weak self] in
                IdentityUtility.switchActiveRole(.patient)
                self?.router?.navigateOnRoleConfirmation(with: self?.viewModel.targetRoute ?? .home)
            },
            onRemoveCaregiver: { [weak self] caregiver in
                self?.displayCaregiverRemovalConfirmationPrompt(for: caregiver)
            }
        )
        
        embedView(patientRoleScreen, to: view)
        
        self.patientRoleScreen = patientRoleScreen
    }
    
    private func configureOwnView() {
        title = "navigation.role.patient".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnView()
        sinkIntoViewModel()
    }
    
    private func sinkIntoOwnView() {
        view.publisher(for: \.safeAreaInsets)
            .map({ min(8.0, $0.top) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                debugPrint(#fileID, #function, $0)
                self?.viewModel.model.updateHeaderTopContentInset($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
    
    // MARK: - Updates
    private func displayCaregiverRemovalConfirmationPrompt(for caregiver: ContactData) {
        let confirmAction = PopupActionData(title: "action.remove".localized(), customStyle: .destructive) { [weak self] in
            self?.viewModel.removeCaregiver(caregiver)
        }
        let cancelAction = PopupActionData(title: "action.cancel".localized(), customStyle: .secondary)
        
        let contactDisplayName = caregiver.contactDisplayName ?? "role.patient.removecaregiver.namefallback".localized()
        let popupData = PopupConfigurationData(
            title: "role.patient.removecaregiver.title".localized(),
            message: "role.patient.removecaregiver.message".localized(arguments: [contactDisplayName]).marking(contactDisplayName, withFont: .withStyle(.paragraph)),
            displaysCloseButton: false,
            primaryAction: confirmAction,
            secondaryAction: cancelAction
        )
        
        AppRouter.current.window.displayPopupView(with: popupData)
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension PatientRoleViewController: Configurable {
    struct ConfigurationData {
        let targetRoute: AppRouter.Root
    }
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        self.viewModel.assignConfigurationData(configurationData)
    }
}

// MARK: Navigable
extension PatientRoleViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .role
    }
}

// MARK: Routable
extension PatientRoleViewController: Routable {
    func assignRouter(_ router: PatientRoleRouter) {
        self.router = router
    }
}

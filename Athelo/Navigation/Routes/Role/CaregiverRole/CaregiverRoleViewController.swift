//
//  CaregiverRoleViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Combine
import UIKit

final class CaregiverRoleViewController: BaseViewController {
    // MARK: - Outlets
    private var caregiverRoleScreen: CaregiverRoleScreen?
    
    // MARK: - Properties
    private let viewModel = CaregiverRoleViewModel()
    private var router: CaregiverRoleRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.updatePatientList()
    }
    
    // MARK: - Configure
    private func configure() {
        configureContentView()
        configureOwnView()
    }
    
    private func configureContentView() {
        if caregiverRoleScreen != nil {
            return
        }
        
        let caregiverRoleScreen = CaregiverRoleScreen(
            model: viewModel.model,
            onAddAWard: { [weak self] in
                self?.router?.navigateToInvitationCodeInput()
            },
            onContinue: { [weak self] patient in
                guard let patientData = (patient as? RelationInterpretationData)?.relatedPerson else {
                    fatalError("Invalid patient data.")
                }
                
                IdentityUtility.switchActiveRole(.caregiver(patientData))
                self?.router?.navigateOnRoleConfirmation()
            }
        )
        
        embedView(caregiverRoleScreen, to: view)
        
        self.caregiverRoleScreen = caregiverRoleScreen
    }
    
    private func configureOwnView() {
        title = "navigation.role.caregiver".localized()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnView()
        sinkIntoRouter()
        sinkIntoViewModel()
    }
    
    private func sinkIntoOwnView() {
        view.publisher(for: \.safeAreaInsets)
            .map({ min(54.0, $0.top) })
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                debugPrint(#fileID, #function, $0)
                self?.viewModel.model.updateHeaderTopContentInset($0)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoRouter() {
        router?.invitationCodeUpdateEventsSubject
            .filter({ $0 == .codeAccepted })
            .receive(on: DispatchQueue.main)
            .sinkDiscardingValue { [weak self] in
                self?.viewModel.updatePatientList()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension CaregiverRoleViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .role
    }
}

// MARK: Routable
extension CaregiverRoleViewController: Routable {
    func assignRouter(_ router: CaregiverRoleRouter) {
        self.router = router
    }
}


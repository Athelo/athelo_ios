//
//  PatientListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Combine
import UIKit

final class PatientListViewController: BaseViewController {
    // MARK: - Outlets
    private var contactListView: ContactListView?
    
    // MARK: - Properties
    private let viewModel = PatientListViewModel()
    private var router: PatientListRouter?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        sink()
        
        viewModel.refresh()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureContactListView()
        configureOwnView()
    }
    
    private func configureContactListView() {
        guard contactListView == nil else {
            return
        }
        
        let actions: [ContactItemAction] = [
            ContactItemAction(
                icon: UIImage(named: "dotsVerticalSolid")!,
                action: { [weak self] contact in
                    self?.displayOptionSheet(for: contact)
                }
            )
        ]
        
        let contactListView = ContactListView(
            model: viewModel.patientListModel,
            actions: actions
        )
        
        embedView(contactListView, to: view)
    }
    
    private func configureOwnView() {
        title = "navigation.mywards".localized()
        
        weak var weakSelf = self
        let item = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: weakSelf, action: #selector(addButtonTapped(_:)))
        
        navigationItem.setRightBarButton(item, animated: true)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoRouter()
        sinkIntoViewModel()
    }
    
    private func sinkIntoRouter() {
        router?.invitationCodeUpdateEventsSubject
            .sinkDiscardingValue { [weak self] in
                self?.viewModel.refresh()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
    
    // MARK: - Updates
    private func displayOptionSheet(for patient: ContactData) {
        let sendMessageAction = OptionSheetItem(
            name: "action.sendamessage".localized(),
            icon: UIImage(named: "envelopeSolid")!,
            action: { [weak self] in
                self?.router?.navigateToChatRoom(with: patient)
            }
        )
        
        let deletePatientAction = OptionSheetItem(
            name: "action.deletepatient".localized(),
            icon: UIImage(named: "trashBinSolid")!,
            destructive: true,
            action: { [weak self] in
                self?.displayPatientRemovalPrompt(for: patient)
            }
        )
        
        let displayedOptions = [sendMessageAction, deletePatientAction]
        AppRouter.current.windowOverlayUtility.displayOptionSheetView(with: displayedOptions)
    }
    
    private func displayPatientRemovalPrompt(for patient: ContactData) {
        let deleteAction = PopupActionData(
            title: "action.delete".localized(),
            customStyle: .destructive,
            action: { [weak self] in
                self?.viewModel.removePatient(patient)
            }
        )
        
        let cancelAction = PopupActionData(
            title: "action.cancel".localized(),
            customStyle: .secondary
        )
        
        let patientDisplayName = patient.contactDisplayName ?? "role.caregiver.removepatient.namefallback".localized()
        var message = "role.caregiver.removepatient.message".localized(arguments: [patientDisplayName])
        if viewModel.hasLastPatient {
            message += "\n\n\("role.caregiver.removepatient.message.lastpatient".localized())"
        }
        
        let configurationData = PopupConfigurationData(
            title: "role.caregiver.removepatient.title".localized(),
            message: message.marking(patientDisplayName, withFont: .withStyle(.intro)),
            primaryAction: deleteAction,
            secondaryAction: cancelAction
        )
        AppRouter.current.windowOverlayUtility.displayPopupView(with: configurationData)
    }
    
    // MARK: - Actions
    @IBAction private func addButtonTapped(_ sender: Any) {
        router?.navigateToInvitationCodeInput()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension PatientListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .contacts
    }
}

// MARK: Routable
extension PatientListViewController: Routable {
    func assignRouter(_ router: PatientListRouter) {
        self.router = router
    }
}

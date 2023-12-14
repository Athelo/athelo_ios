//
//  CaregiverListViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Combine
import UIKit

final class CaregiverListViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var pickerViewActiveTab: SegmentedPickerView!
    @IBOutlet private weak var viewContentContainer: UIView!
    
    private var listView: CaregiverListScreen?
    
    // MARK: - Properties
    private let viewModel = CaregiverListViewModel()
    private var router: CaregiverListRouter?
    
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
        configureActiveTabPickerView()
        configureListView()
        configureOwnView()
    }
    
    private func configureActiveTabPickerView() {
        pickerViewActiveTab.assignOptions(CaregiverListTab.allCases.map({ $0.name }), preselecting: CaregiverListTab.allCases.firstIndex(of: .caregivers) ?? 0)
    }
    
    private func configureListView() {
        guard listView == nil else {
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
        
        let listView = CaregiverListScreen(
            model: viewModel.dataModel,
            caregiverActions: actions,
            onDeleteInvitation: { [weak self] invitation in
                self?.displayInvitationCancellationConfirmationPrompt(for: invitation)
            }
        )
        
        embedView(listView, to: viewContentContainer)
        
        self.listView = listView
    }
    
    private func configureOwnView() {
        title = "navigation.mycaregivers".localized()
        
        weak var weakSelf = self
        let item = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: weakSelf, action: #selector(addButtonTapped(_:)))
        
        navigationItem.setRightBarButton(item, animated: true)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoActiveTabPickerView()
        sinkIntoRouter()
        sinkIntoViewModel()
    }
    
    private func sinkIntoActiveTabPickerView() {
        pickerViewActiveTab.selectedItemPublisher
            .compactMap({ CaregiverListTab.allCases[safe: $0] })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.viewModel.dataModel.updateActiveTab(value)
            }.store(in: &cancellables)
    }
    
    private func sinkIntoRouter() {
        router?.inviteCaregiverUpdateEventsSubject
            .sinkDiscardingValue { [weak self] in
                self?.viewModel.refreshInvitationList()
            }.store(in: &cancellables)
    }
    
    private func sinkIntoViewModel() {
        bindToViewModel(viewModel, cancellables: &cancellables)
    }
    
    // MARK: - Updates
    private func displayCaregiverRemovalPrompt(for caregiver: ContactData) {
        let deleteAction = PopupActionData(
            title: "action.delete".localized(),
            customStyle: .destructive,
            action: { [weak self] in
                self?.viewModel.removeCaregiver(caregiver)
            }
        )
        
        let cancelAction = PopupActionData(
            title: "action.cancel".localized(),
            customStyle: .secondary
        )
        
        let caregiverDisplayName = caregiver.contactDisplayName ?? "role.patient.removecaregiver.namefallback".localized()
        let configurationData = PopupConfigurationData(
            title: "role.patient.removecaregiver.title".localized(),
            message: "role.patient.removecaregiver.message".localized(arguments: [caregiverDisplayName]).marking(caregiverDisplayName, withFont: .withStyle(.intro)),
            primaryAction: deleteAction,
            secondaryAction: cancelAction
        )
        AppRouter.current.windowOverlayUtility.displayPopupView(with: configurationData)
    }
    
    private func displayInvitationCancellationConfirmationPrompt(for invitation: HealthInvitationData) {
        let deleteAction = PopupActionData(
            title: "action.revoke".localized(),
            customStyle: .destructive,
            action: { [weak self] in
                self?.viewModel.cancelInvitation(invitation)
            }
        )
        
        let cancelAction = PopupActionData(
            title: "action.cancel".localized(),
            customStyle: .secondary
        )
        
        let configurationData = PopupConfigurationData(
            title: "popup.deleteinvitation.title".localized(),
            message: "popup.deleteinvitation.message".localized(arguments: [invitation.receiverNickName]).marking(invitation.receiverNickName, withFont: .withStyle(.intro)),
            primaryAction: deleteAction,
            secondaryAction: cancelAction
        )
        
        AppRouter.current.windowOverlayUtility.displayPopupView(with: configurationData)
    }
    
    private func displayOptionSheet(for caregiver: ContactData) {
        let sendMessageAction = OptionSheetItem(
            name: "action.sendamessage".localized(),
            icon: UIImage(named: "envelopeSolid")!,
            action: { [weak self] in
                self?.router?.navigateToChatRoom(with: caregiver)
            }
        )
        
        let deleteCaregiverAction = OptionSheetItem(
            name: "action.deletecaregiver".localized(),
            icon: UIImage(named: "trashBinSolid")!,
            destructive: true,
            action: { [weak self] in
                self?.displayCaregiverRemovalPrompt(for: caregiver)
            }
        )
        
        let displayedOptions = [sendMessageAction, deleteCaregiverAction]
        AppRouter.current.windowOverlayUtility.displayOptionSheetView(with: displayedOptions)
    }
    
    // MARK: - Actions
    @IBAction private func addButtonTapped(_ sender: Any) {
        router?.navigateToCaregiverInvitationForm()
    }
}

// MARK: - Protocol conformance
// MARK: Navigable
extension CaregiverListViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .contacts
    }
}

// MARK: Routable
extension CaregiverListViewController: Routable {
    func assignRouter(_ router: CaregiverListRouter) {
        self.router = router
    }
}

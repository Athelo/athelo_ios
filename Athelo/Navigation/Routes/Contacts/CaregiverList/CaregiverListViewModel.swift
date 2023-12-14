//
//  CaregiverListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Combine
import Foundation

final class CaregiverListViewModel: BaseViewModel {
    // MARK: - Properties
    lazy private(set) var dataModel: CaregiverListModel = {
        CaregiverListModel(caregiversModel: caregiversModel, invitationsModel: invitationsModel)
    }()
    
    let caregiversModel = ContactListModel(contacts: [])
    let invitationsModel = InvitationListModel()
    
    private var cancellables: [AnyCancellable] = []
    private var caregiverListUpdateCancellable: AnyCancellable?
    
    // MARK: - Public API
    func cancelInvitation(_ invitation: HealthInvitationData) {
        guard state.value != .loading else {
            return
        }
        
        guard invitationsModel.invitations.contains(where: { $0.id == invitation.id }) else {
            return
        }
        
        state.value = .loading
        
        let cancelInvitationRequest = HealthCancelInvitationRequest(invitationID: invitation.id)
        AtheloAPI.Health.cancelInvitation(request: cancelInvitationRequest)
            .sink { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.state.send(.error(error: error))
                case .finished:
                    self?.refreshInvitationList(updatingStateOnSuccess: true)
                }
            }.store(in: &cancellables)
    }
    
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        refreshInvitationList()
        
        if caregiverListUpdateCancellable != nil {
            IdentityUtility.refreshCaregiverData()
            return
        }
        
        guard let caregiversPublisher = IdentityUtility.refreshCaregiverData() else {
            return
        }
        
        state.value = .loading
        
        caregiversPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.caregiversModel.updateContacts(value, animated: true)
            }.store(in: &cancellables)

        sinkIntoCaregiversListUpdate()
    }
    
    func refreshInvitationList(updatingStateOnSuccess: Bool = false) {
        let request = HealthInvitationsRequest(statuses: [.sent])
        (AtheloAPI.Health.invitationList(request: request) as AnyPublisher<ListResponseData<HealthInvitationData>, APIError>)
            .repeating()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    if updatingStateOnSuccess {
                        self?.state.send(.loaded)
                    }
                case .failure(let error):
                    self?.state.send(.error(error: error))
                }
            } receiveValue: { [weak self] value in
                self?.invitationsModel.updateInvitations(value, animated: true)
            }.store(in: &cancellables)
    }
    
    func removeCaregiver(_ caregiver: ContactData) {
        guard state.value != .loading else {
            return
        }
        
        guard caregiversModel.contacts.contains(where: { $0.contactID == caregiver.contactID }) else {
            return
        }
        
        state.value = .loading
        
        let caregiverRemovalRequest = HealthRemoveCaregiverRequest(caregiverID: caregiver.contactID)
        AtheloAPI.Health.removeCaregiver(request: caregiverRemovalRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
                
                if case .finished = result {
                    self?.caregiversModel.removeContact(caregiver, animated: true)
                    
                    self?.sinkIntoCaregiversListUpdate()
                    IdentityUtility.refreshCaregiverData()
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sinkIntoCaregiversListUpdate() {
        guard caregiverListUpdateCancellable == nil else {
            return
        }
        
        caregiverListUpdateCancellable = IdentityUtility.$caregivers
            .dropFirst()
            .map({ $0 ?? [] })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.caregiversModel.updateContacts(value)
            }
    }
}

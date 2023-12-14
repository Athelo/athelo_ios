//
//  PatientRoleViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Combine
import Foundation

// TODO: Ask if pending invitation data should be displayed on this list.
// TODO: Check if caregiver data updates are reflected in UI.
final class PatientRoleViewModel: BaseViewModel {
    // MARK: - Properties
    let model = PatientRoleModel()
    
    private(set) var targetRoute: AppRouter.Root = .home
    
    private var cancellables: [AnyCancellable] = []
    private var listUpdateCancellable: AnyCancellable?
    
    // MARK: - Public API
    func assignConfigurationData(_ configurationData: PatientRoleViewController.ConfigurationData) {
        self.targetRoute = configurationData.targetRoute
    }
    
    func updateCaregiverList() {
        if listUpdateCancellable != nil {
            IdentityUtility.refreshCaregiverData()
            return
        }
        
        guard state.value != .loading else {
            return
        }
        
        state.value = .loading
        
        callForCaregiverList()
    }
    
    func removeCaregiver(_ caregiver: ContactData) {
        guard model.caregivers.contains(where: { $0.contactID == caregiver.contactID }) else {
            return
        }
        
        guard state.value != .loading else {
            return
        }
        
        state.value = .loading
        
        callForCaregiverRemoval(caregiverID: caregiver.contactID)
    }
    
    // MARK: - API calls
    private func callForCaregiverList() {
        guard let publisher = IdentityUtility.refreshCaregiverData() else {
            state.send(.error(error: CommonError.missingCredentials))
            return
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.updateCaregiverData(value)
            }.store(in: &cancellables)
        
        sinkIntoIdentityUtility()
    }
    
    private func callForCaregiverRemoval(caregiverID: Int) {
        let request = HealthRemoveCaregiverRequest(caregiverID: caregiverID)
        AtheloAPI.Health.removeCaregiver(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
                
                if case .finished = result {
                    self?.model.removeCaregiver(caregiverID: caregiverID, animated: true)
                    self?.sinkIntoIdentityUtility(clearingExistingListener: true)
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sinkIntoIdentityUtility(clearingExistingListener: Bool = false) {
        if !clearingExistingListener {
            guard listUpdateCancellable == nil else {
                return
            }
        }
        
        listUpdateCancellable?.cancel()
        listUpdateCancellable = IdentityUtility.$caregivers
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateCaregiverData(value ?? [])
            }
    }
    
    // MARK: - Data updates
    private func updateCaregiverData(_ caregivers: [ContactData]) {
        model.updateCaregivers(caregivers, animated: model.revealed)
        model.reveal()
    }
}

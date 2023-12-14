//
//  PatientListViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Combine
import Foundation

final class PatientListViewModel: BaseViewModel {
    // MARK: - Properties
    let patientListModel = ContactListModel(contacts: [])
    var hasLastPatient: Bool {
        patientListModel.contacts.count == 1
    }
    
    private var cancellables: [AnyCancellable] = []
    private var patientListUpdateCancellable: AnyCancellable?
    
    // MARK: - Public API
    func refresh() {
        guard state.value != .loading else {
            return
        }
        
        if patientListUpdateCancellable != nil {
            IdentityUtility.refreshPatientData()
            return
        }
        
        guard let contactsPublisher = IdentityUtility.refreshPatientData() else {
            return
        }
        
        state.value = .loading
        
        contactsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.patientListModel.updateContacts(value)
            }.store(in: &cancellables)
        
        sinkIntoPatientListUpdates()
    }
    
    func removePatient(_ patient: ContactData) {
        guard state.value != .loading else {
            return
        }
        
        guard IdentityUtility.patients?.contains(where: { $0.contactID == patient.contactID }) == true else {
            return
        }
        
        state.value = .loading
        
        let patientRemovalRequest = HealthRemovePatientRequest(patientID: patient.contactID)
        AtheloAPI.Health.removePatient(request: patientRemovalRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
                
                if case .finished = result {
                    self?.patientListModel.removeContact(patient, animated: true)
                    
                    self?.sinkIntoPatientListUpdates()
                    IdentityUtility.refreshPatientData()
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sinkIntoPatientListUpdates() {
        guard patientListUpdateCancellable == nil else {
            return
        }
        
        patientListUpdateCancellable = IdentityUtility.$patients
            .dropFirst()
            .map({ $0 ?? [] })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.patientListModel.updateContacts(value)
            }
    }
}

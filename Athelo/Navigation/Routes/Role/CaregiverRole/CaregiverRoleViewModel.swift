//
//  CaregiverRoleViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Combine
import Foundation

final class CaregiverRoleViewModel: BaseViewModel {
    // MARK: - Properties
    let model = CaregiverRoleModel()
    
    private var cancellables: [AnyCancellable] = []
    private var listUpdateCancellable: AnyCancellable?
    
    // MARK: - Public API
    func updatePatientList() {
        if listUpdateCancellable != nil {
            IdentityUtility.refreshPatientData()
            return
        }
        
        guard state.value != .loading else {
            return
        }
        
        state.value = .loading
        
        callForPatientList()
    }
    
    // MARK: - API calls
    private func callForPatientList() {
        guard let publisher = IdentityUtility.refreshPatientData() else {
            state.send(.error(error: CommonError.missingCredentials))
            return
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.updatePatientData(value)
            }.store(in: &cancellables)
        
        sinkIntoIdentityUtility()
    }
    
    // MARK: - Sinks
    private func sinkIntoIdentityUtility() {
        guard listUpdateCancellable == nil else {
            return
        }
        
        listUpdateCancellable = IdentityUtility.$patients
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updatePatientData(value ?? [])
            }
    }
    
    // MARK: - Data updates
    private func updatePatientData(_ patients: [ContactData]) {
        model.updatePatients(patients, animated: model.revealed)
        model.reveal()
    }
}

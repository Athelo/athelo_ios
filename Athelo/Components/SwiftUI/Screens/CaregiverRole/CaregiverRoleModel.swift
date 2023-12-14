//
//  CaregiverRoleModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/02/2023.
//

import Combine
import Foundation
import SwiftUI

final class CaregiverRoleModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var headerTopContentInset: CGFloat = 0.0
    @Published private(set) var patients: [ContactData] = []
    @Published private(set) var selectedPatient: ContactData?
    @Published private(set) var revealed: Bool = false
    
    let registeringUser: Bool
    var hasPatients: Bool {
        !patients.isEmpty
    }
    
    // MARK: - Initialization
    init(registeringUser: Bool = false) {
        self.registeringUser = registeringUser
    }
    
    // MARK: - Public API
    func reveal() {
        guard !revealed else {
            return
        }
        
        withAnimation {
            self.revealed = true
        }
    }
    
    func selectPatient(_ patient: ContactData) {
        if patients.contains(where: { $0.contactID == patient.contactID }) {
            selectedPatient = patient
        }
    }
    
    func updateHeaderTopContentInset(_ inset: CGFloat, animated: Bool = false) {
        if(inset != headerTopContentInset) {
            withExplicitAnimation(animated) {
                headerTopContentInset = max(0.0, inset)
            }
        }
    }
    
    func updatePatients(_ patients: [ContactData], animated: Bool = false) {
        withExplicitAnimation(animated) {
            self.patients = patients
            
            if let selectedPatient, !patients.contains(where: { $0.contactID == selectedPatient.contactID }) {
                self.selectedPatient = nil
            }
        }
    }
}

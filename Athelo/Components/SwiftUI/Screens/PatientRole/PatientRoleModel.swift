//
//  PatientRoleModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation
import SwiftUI

final class PatientRoleModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var caregivers: [ContactData] = []
    @Published private(set) var headerTopContentInset: CGFloat = 0.0
    @Published private(set) var revealed: Bool = false
    
    var hasCaregivers: Bool {
        !caregivers.isEmpty
    }
    
    // MARK: - Public API
    func reveal() {
        guard !revealed else {
            return
        }
        
        withAnimation {
            revealed = true
        }
    }
    
    func updateCaregivers(_ caregivers: [ContactData], animated: Bool = false) {
        withExplicitAnimation(animated) {
            self.caregivers = caregivers
        }
    }
    
    func updateHeaderTopContentInset(_ inset: CGFloat, animated: Bool = false) {
        if(inset != headerTopContentInset) {
            withExplicitAnimation(animated) {
                headerTopContentInset = max(0.0, inset)
            }
        }
    }
    
    func removeCaregiver(caregiverID: Int, animated: Bool = false) {
        guard let caregiverIndex = caregivers.firstIndex(where: { $0.contactID == caregiverID }) else {
            return
        }
        
        withExplicitAnimation(animated) {
            if self.caregivers.indices ~= caregiverIndex {
                self.caregivers.remove(at: caregiverIndex)
            }
        }
    }
}

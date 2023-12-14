//
//  AddContactViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/09/2022.
//

import Combine
import UIKit

final class AddContactViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var isValid: Bool = false
    
    private let phoneNumber = CurrentValueSubject<String?, Never>(nil)
    private let userName = CurrentValueSubject<String?, Never>(nil)
    
    private(set) var userRole: UserRole = .caregiver
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignPhoneNumber(_ phoneNumber: String?) {
        self.phoneNumber.send(phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func assignUserName(_ userName: String?) {
        self.userName.send(userName?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func assignUserRole(_ userRole: UserRole) {
        self.userRole = userRole
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        Publishers.CombineLatest(
            phoneNumber.map({ $0?.isEmpty == false }),
            userName.map({ $0?.isEmpty == false })
        )
        .map({ $0 && $1 })
        .removeDuplicates()
        .sink { [weak self] in
            self?.isValid = $0
        }.store(in: &cancellables)
    }
}

//
//  InviteCaregiverViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/03/2023.
//

import Combine
import Foundation

final class InviteCaregiverViewModel: BaseViewModel {
    // MARK: - Properties
    private let email = CurrentValueSubject<String?, Never>(nil)
    private let name = CurrentValueSubject<String?, Never>(nil)
    private let successMessageSubject = PassthroughSubject<String, Never>()
    
    var successMessagePublisher: AnyPublisher<String, Never> {
        successMessageSubject.eraseToAnyPublisher()
    }
    
    @Published private(set) var relationType: CaregiverRelationLabelConstant?
    @Published private(set) var isValid: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignEmail(_ email: String?) {
        self.email.send(email)
    }
    
    func assignName(_ name: String?) {
        self.name.send(name)
    }
    
    func assignRelationType(_ relationType: CaregiverRelationLabelConstant) {
        self.relationType = relationType
    }
    
    func clearFormData() {
        email.send(nil)
        name.send(nil)
        relationType = nil
    }
    
    func relationTypesPublisher() -> AnyPublisher<[ListInputCellItemData], Error> {
        Deferred {
            ConstantsStore.constantsPublisher()
                .map({ $0.caregiverRelationLabels })
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func sendRequest() {
        guard state.value != .loading, isValid,
              let email = email.value,
              let name = name.value,
              let relationType else {
            return
        }
        
        state.send(.loading)
        
        let request = HealthInviteCaregiverRequest(caregiverNickName: name, email: email, relationLabel: relationType.key)
        (AtheloAPI.Health.inviteCaregiver(request: request) as AnyPublisher<HealthInvitationData, APIError>)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
                
                if case .finished = result {
                    self?.successMessageSubject.send("invitation.caregiver.success".localized(arguments: [name]))
                    self?.clearFormData()
                }
            } receiveValue: { _ in
                /* ... */
            }.store(in: &cancellables)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validEmailPublisher = email.map({ EmailValidator.validate($0).isValid }).eraseToAnyPublisher()
        let validNamePublisher = name.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validRelationTypePublisher = $relationType.map({ $0 != nil }).eraseToAnyPublisher()
        
        Publishers.CombineLatest3(
            validEmailPublisher,
            validNamePublisher,
            validRelationTypePublisher
        )
        .map({ $0 && $1 && $2 })
        .removeDuplicates()
        .sink { [weak self] in
            self?.isValid = $0
        }.store(in: &cancellables)
    }
}

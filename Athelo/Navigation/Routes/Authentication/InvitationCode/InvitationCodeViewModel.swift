//
//  InvitationCodeViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/09/2022.
//

import Combine
import Foundation

final class InvitationCodeViewModel: BaseViewModel {
    // MARK: - Properties
    private let invitationCode = CurrentValueSubject<Array<Optional<String>>, Never>((0...5).map({ _ in Optional(nil) }))
    private let successMessageSubject = PassthroughSubject<String, Never>()
    
    var successMessagePublisher: AnyPublisher<String, Never> {
        successMessageSubject.eraseToAnyPublisher()
    }
    
    @Published private(set) var isValid: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func updateDigit(_ digit: String?, at index: Int) {
        guard invitationCode.value.indices ~= index else {
            return
        }
        
        invitationCode.value[index] = digit
    }
    
    func sendRequest() {
        guard state.value != .loading else {
            return
        }
            
        let code = invitationCode.value.compactMap({ $0 }).joined()
        guard code.count == 6 else {
            return
        }
        
        state.value = .loading
        
        callInvitationCodeRequest(with: code)
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        invitationCode
            .map({ $0.compactMap({ $0 }).count == 6 })
            .removeDuplicates()
            .sink { [weak self] value in
                self?.isValid = value
            }.store(in: &cancellables)
    }
    
    // MARK: - API calls
    private func callInvitationCodeRequest(with invitationCode: String) {
        let request = HealthAcceptCaregiverInvitationRequest(invitationCode: invitationCode)
        AtheloAPI.Health.acceptCaregiverInvitation(request: request)
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
                
                if case .finished = result {
                    self?.successMessageSubject.send("invitation.patient.success".localized())
                }
            }.store(in: &cancellables)
    }
}

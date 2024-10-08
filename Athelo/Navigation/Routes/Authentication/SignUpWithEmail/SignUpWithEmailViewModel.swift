//
//  SignUpWithEmailViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import UIKit

final class SignUpWithEmailViewModel: BaseViewModel {
    // MARK: - Properties
    private let confirmPassword = CurrentValueSubject<String?, Never>(nil)
    private let email = CurrentValueSubject<String?, Never>(nil)
    private let password = CurrentValueSubject<String?, Never>(nil)
    
    @Published private(set) var formErrors: [AuthFormError]? = nil
    @Published private(set) var isValid: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignConfirmPassword(_ confirmPassword: String?) {
        self.confirmPassword.send(confirmPassword)
    }
    
    func assignEmail(_ email: String?) {
        self.email.send(email)
    }
    
    func assignPassword(_ password: String?) {
        self.password.send(password)
    }
    
    func sendRequest() {
        guard isValid, state.value != .loading,
              let confirmPassword = confirmPassword.value,
              let email = email.value,
              let password = password.value else {
            return
        }
        
        state.send(.loading)
        
        IdentityUtility.register(email: email, password: password, confirmPassword: confirmPassword)
            .sink { [weak self] in
                self?.state.send($0.toViewModelState())
            }.store(in: &cancellables)
    }
    
    // MARK: - Sink
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validConfirmPasswordPublisher = confirmPassword.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validEmailPublisher = email.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validPasswordPublisher = password.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        
        Publishers.CombineLatest3(
            validConfirmPasswordPublisher,
            validEmailPublisher,
            validPasswordPublisher
        )
        .map({ $0 && $1 && $2 })
        .removeDuplicates()
        .sink { [weak self] in
            self?.isValid = $0
        }.store(in: &cancellables)
            
        state
            .toError(of: APIError.self)
            .compactMap({ AuthFormError.formErrors(from: $0) })
            .filter({ !$0.isEmpty })
            .sink { [weak self] in
                self?.formErrors = $0
            }.store(in: &cancellables)
    }
}

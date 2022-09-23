//
//  ChangePasswordViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/06/2022.
//

import Combine
import UIKit

final class ChangePasswordViewModel: BaseViewModel {
    // MARK: - Properties
    private let confirmPassword = CurrentValueSubject<String?, Never>(nil)
    private let currentPassword = CurrentValueSubject<String?, Never>(nil)
    private let password = CurrentValueSubject<String?, Never>(nil)
    
    @Published private(set) var formErrors: [AuthFormError]? = nil
    @Published private(set) var isValid: Bool = false
    @Published private(set) var successMessage: String?
    
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
    
    func assignCurrentPassword(_ currentPassword: String?) {
        self.currentPassword.send(currentPassword)
    }
    
    func assignPassword(_ password: String?) {
        self.password.send(password)
    }
    
    func sendRequest() {
        guard isValid, state.value != .loading,
              let confirmPassword = confirmPassword.value,
              let currentPassword = currentPassword.value,
              let password = password.value else {
            return
        }
        
        state.send(.loading)
        
        let request = PasswordChangeRequest(oldPassword: currentPassword, newPassword: password, newPasswordRepeated: confirmPassword)
        AtheloAPI.Passwords.change(request: request)
            .sink { [weak self] in
                if case .finished = $0 {
                    self?.confirmPassword.send(nil)
                    self?.currentPassword.send(nil)
                    self?.password.send(nil)
                }
                
                self?.state.send($0.toViewModelState())
            } receiveValue: { [weak self] in
                self?.successMessage = $0.detail
            }.store(in: &cancellables)
    }
    
    // MARK: - Sink
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validConfirmPasswordPublisher = confirmPassword.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validCurrentPasswordPublisher = currentPassword.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validPasswordPublisher = password.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        
        Publishers.CombineLatest3(
            validConfirmPasswordPublisher,
            validCurrentPasswordPublisher,
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

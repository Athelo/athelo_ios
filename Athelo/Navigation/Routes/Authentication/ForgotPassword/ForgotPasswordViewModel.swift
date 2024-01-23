//
//  ForgotPasswordViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import UIKit
import FirebaseAuth

final class ForgotPasswordViewModel: BaseViewModel {
    // MARK: - Properties
    private let emailSubject = CurrentValueSubject<String?, Never>(nil)
    var email: String? {
        emailSubject.value
    }

    @Published private(set) var formErrors: [AuthFormError] = []
    @Published private(set) var isValid: Bool = false
    
    private let successMessageSubject = PassthroughSubject<String, Never>()
    var successMessagePublisher: AnyPublisher<String, Never> {
        successMessageSubject.eraseToAnyPublisher()
    }
    
    private var cancellables: [AnyCancellable] = []

    // MARK: - Initialization
    override init() {
        super.init()

        sink()
    }

    // MARK: - Public API
    func assignEmail(_ email: String?) {
        self.emailSubject.send(email)
    }

    func sendRequest() {
        guard state.value != .loading, isValid,
              let email = emailSubject.value else {
            return
        }

        state.send(.loading)
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let error = error else {
                self?.state.send(.loaded)
                self?.successMessageSubject.send("action.passwordreset.send".localized())
                return
            }
            self?.state.send(.error(error: error))
        }
        

//        let request = PasswordResetRequest(email: email, type: .link)
//        AtheloAPI.Passwords.reset(request: request)
//            .sink { [weak self] result in
//                switch result {
//                case .finished:
//                    self?.state.send(.loaded)
//                case .failure(let error):
//                    self?.state.send(.error(error: error))
//                }
//            } receiveValue: { [weak self] value in
//                self?.successMessageSubject.send(value.detail)
//            }.store(in: &cancellables)
    }

    // MARK: - Sinks
    private func sink() {
        sinkIntoOwnSubjects()
    }

    private func sinkIntoOwnSubjects() {
        emailSubject.map({ $0?.isEmpty == false })
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

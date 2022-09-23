//
//  LogInViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Combine
import UIKit

final class LogInViewModel: BaseViewModel {
    private let email = CurrentValueSubject<String?, Never>(nil)
    private let password = CurrentValueSubject<String?, Never>(nil)

    @Published private(set) var formErrors: [AuthFormError]?
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

    func assignPassword(_ password: String?) {
        self.password.send(password)
    }

    func logIn() {
        guard state.value != .loading, isValid,
              let email = email.value,
              let password = password.value else {
            return
        }

        state.send(.loading)
        
        IdentityUtility.login(email: email, password: password)
            .sink { [weak self] in
                switch $0 {
                case .finished:
                    self?.state.send(.loaded)
                case .failure(let error):
                    if case .missingCredentials = (error as? APIError) {
                        self?.state.send(.error(error: AuthenticationPingError()))
                    } else {
                        self?.state.send(.error(error: error))
                    }
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
        let validEmailPublisher = email.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validPasswordPublisher = password.map({ $0?.isEmpty == false }).eraseToAnyPublisher()

        validEmailPublisher
            .combineLatest(validPasswordPublisher)
            .map({ $0 && $1 })
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

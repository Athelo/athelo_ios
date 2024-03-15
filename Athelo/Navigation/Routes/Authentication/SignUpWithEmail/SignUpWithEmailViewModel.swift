//
//  SignUpWithEmailViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import UIKit
import FirebaseAuth

public struct SignUpWithEmailData: APIRequest {
    public var parameters: [String : Any]?
    
    let email: String
    let display_name: String
    let first_name: String
    let last_name: String
}

final class SignUpWithEmailViewModel: BaseViewModel {
    // MARK: - Properties
    private let userName = CurrentValueSubject<String?, Never>(nil)
    private let email = CurrentValueSubject<String?, Never>(nil)
    private let password = CurrentValueSubject<String?, Never>(nil)
    private let confirmPassword = CurrentValueSubject<String?, Never>(nil)
    
    @Published private(set) var formErrors: [AuthFormError]? = nil
    @Published private(set) var isValid: Bool = false
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Public API
    func assignUserName(_ userName: String?) {
        self.userName.send(userName)
    }
    
    func assignEmail(_ email: String?) {
        self.email.send(email)
    }
    
    func assignPassword(_ password: String?) {
        self.password.send(password)
    }
    
    func assignConfirmPassword(_ confirmPassword: String?) {
        self.confirmPassword.send(confirmPassword)
    }
    
    func sendRequest() {
        guard isValid, state.value != .loading,
              let displayName = userName.value,
              let confirmPassword = confirmPassword.value,
              let email = email.value,
              let password = password.value,
              password == confirmPassword else {
            return
        }
        
        state.send(.loading)
        
//        IdentityUtility.register(email: email, password: password, confirmPassword: confirmPassword)
//            .sink { [weak self] in
//                self?.state.send($0.toViewModelState())
//            }.store(in: &cancellables)
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
        
        IdentityUtility.logOut()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let authResult = authResult else {
                guard let error = error else {
                    self?.state.send(.error(error: AuthenticationPingError()))
                    return
                }
                self?.state.send(.error(error: error))
                return
            }
            authResult.user.getIDToken(completion: { [weak self] token, error in
                guard let token = token, let email = authResult.user.email, let refreshToken = authResult.user.refreshToken else {
                    self?.state.send(.error(error: error ?? AuthenticationPingError()))
                    return
                }
                let tokenData =  IdentityTokenData(accessToken: token, 
                                                   expiresIn: 24000,
                                                   refreshToken: refreshToken,
                                                   scope: "",
                                                   tokenType: "email")
                do {
                    try APIEnvironment.setUserToken(tokenData)
                } catch {
                    
                }
                self?.createProfile(email: email, displayName: displayName, tokenData: tokenData)
            })
        }
    }
    
    private func createProfile(email: String, displayName: String, tokenData: IdentityTokenData) {
        let deeplinkPath = UserDefaults.standard.string(forKey: "deepLinkPath")
        UserDefaults.standard.removeObject(forKey: "deepLinkPath")
        let request = ProfileCreateRequest1(additionalParams: [
            "display_name": displayName,
            "first_name": "",
            "last_name": "",
            "code" : deeplinkPath == nil ? "" : deeplinkPath!
        ])
        
        (AtheloAPI.Profile.createProfile(request: request) as AnyPublisher<IdentityProfileData, APIError>)
            .mapError({
                $0 as Error
            })
            .handleEvents(receiveOutput: { value in
            })
            .map({_ in
               
            }).sink(receiveCompletion: {_ in
                self.setToken(tokenData: tokenData, email: email, displayName: displayName)
            }, receiveValue: {
                
            }).store(in: &cancellables)
    }
    
    private func setToken(tokenData: IdentityTokenData, email: String, displayName: String) {
        IdentityUtility.setToken(tokenData: tokenData, email: email)
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
    
    // MARK: - Sink
    private func sink() {
        sinkIntoOwnSubjects()
    }
    
    private func sinkIntoOwnSubjects() {
        let validUserName = userName.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validEmailPublisher = email.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validPasswordPublisher = password.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        let validConfirmPasswordPublisher = confirmPassword.map({ $0?.isEmpty == false }).eraseToAnyPublisher()
        Publishers.CombineLatest4(
            validUserName,
            validConfirmPasswordPublisher,
            validEmailPublisher,
            validPasswordPublisher
        )
        .map({ $0 && $1 && $2 && $3 })
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

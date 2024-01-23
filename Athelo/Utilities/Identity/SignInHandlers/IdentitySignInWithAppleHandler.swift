//
//  IdentitySignInWithAppleHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/06/2022.
//

import AuthenticationServices
import Combine
import UIKit
import FirebaseAuth

final class IdentitySignInWithAppleHandler: NSObject {
    // MARK: Constants
    enum AppleAuthError: ThirdPartyAuthenticationError {
        case invalidCredentials
        case missingCredentials
        case sheetDismissed
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "error.apple.revoked".localized()
            case .missingCredentials, .sheetDismissed:
                return "error.apple.credentials".localized()
            }
        }
        
        var isSheetDismissedError: Bool {
            self == .sheetDismissed
        }
    }
    
    // MARK: - Properties
    private let state = CurrentValueSubject<SignInHandlerState, Never>(.initial)
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func performLoginAttempt() -> AnyPublisher<SignInHandlerState, Never> {
        guard state.value != .loading else {
            return state.eraseToAnyPublisher()
        }
    
        state.value = .loading
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        return state.eraseToAnyPublisher()
    }
}

// MARK: - Protocol conformance
// MARK: ASAuthorizationControllerDelegate
extension IdentitySignInWithAppleHandler: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authorizationCode = credential.identityToken,
              let encodedAuthCode = String(data: authorizationCode, encoding: .utf8) else {
            state.send(.error(error: AppleAuthError.missingCredentials))
            return
        }
        let cred = OAuthProvider.appleCredential(withIDToken: encodedAuthCode, rawNonce: nil, fullName: credential.fullName)
        Auth.auth().signIn(with: cred) { [weak self] authResult, error in
            guard let authResult = authResult, let email = authResult.user.email, let refreshToken = authResult.user.refreshToken else {
                guard let error = error else {
                    self?.state.send(.error(error: AuthenticationPingError()))
                    return
                }
                self?.state.send(.error(error: error))
                return
            }
            authResult.user.getIDToken(completion: { [weak self] token, error in
                guard let token = token else {
                    self?.state.send(.error(error: error ?? AuthenticationPingError()))
                    return
                }
                let provider = authResult.credential?.provider
                
                let tokenData =  IdentityTokenData(accessToken: token, expiresIn: 24000, refreshToken: refreshToken, scope: "", tokenType: provider ?? "google")
                self?.state.send(.loaded(token: tokenData, email: email))
            })
        }
        
//        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: credential.user) { [weak self] state, error in
//            guard let self = self else {
//                return
//            }
//            
//            guard state == .authorized else {
//                self.state.send(.error(error: error ?? AppleAuthError.invalidCredentials))
//                return
//            }
//            
//            let email = credential.email
//            let fullName = credential.fullName
//            let request = AuthenticationLoginWithSocialProfileRequest(provider: "apple-id", token: encodedAuthCode)
//            
//            AtheloAPI.Authentication.loginUsingSocialProfile(request: request)
//                .sink { [weak self] result in
//                    if case .failure(let error) = result {
//                        self?.state.send(.error(error: error))
//                    }
//                } receiveValue: { [weak self] value in
//                    self?.state.send(.loaded(token: value.tokenData, email: email))
//                }.store(in: &self.cancellables)
//        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if ASAuthorizationError(_nsError: error as NSError).code == .canceled {
            state.send(.error(error: AppleAuthError.sheetDismissed))
            return
        }
        
        state.send(.error(error: error))
    }
}

// MARK: ASAuthorizationControllerPresentationContextProviding
extension IdentitySignInWithAppleHandler: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = (Array(UIApplication.shared.connectedScenes).first?.delegate as? SceneDelegate)?.window else {
            fatalError("Missing window instance for displaying Sign in with Apple UI.")
        }
        
        return window
    }
}

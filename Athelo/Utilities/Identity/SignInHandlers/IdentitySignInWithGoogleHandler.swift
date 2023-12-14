//
//  IdentitySignInWithGoogleHandler.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/06/2022.
//

import Combine
import FirebaseCore
import GoogleSignIn
import UIKit

protocol IdentitySignInWithGoogleUIProvider {
    var signInWithGooglePresentingViewController: UIViewController { get }
}

final class IdentitySignInWithGoogleHandler {
    // MARK: Constants
    enum GoogleAuthError: ThirdPartyAuthenticationError {
        case missingAccessToken
        case missingClientID
        case missingPresentingUI
        case sheetDismissed
        
        var errorDescription: String? {
            "error.google.credentials".localized()
        }
        
        var isSheetDismissedError: Bool {
            self == .sheetDismissed
        }
    }
    
    // MARK: - Properties
    private let state = CurrentValueSubject<SignInHandlerState, Never>(.initial)
    
    private var cancellables: [AnyCancellable] = []
    private var thirdPartyCancellable: AnyCancellable? = nil
    
    // MARK: - Public API
    func performLoginAttempt(uiProvider: IdentitySignInWithGoogleUIProvider? = nil) -> AnyPublisher<SignInHandlerState, Never> {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            state.send(.error(error: GoogleAuthError.missingClientID))
            return state.eraseToAnyPublisher()
        }
        
        guard state.value != .loading else {
            return state.eraseToAnyPublisher()
        }
        
        state.send(.loading)
        
        Task { [weak self] in
            do {
                let config = GIDConfiguration(clientID: clientID)
                guard let tokenValue = try await self?.sendTokenRequest(using: config, uiProvider: uiProvider) else {
                    throw GoogleAuthError.missingAccessToken
                }
                
                self?.sendLoginRequest(using: tokenValue.token, email: tokenValue.email)
            } catch {
                if (error as NSError).domain == kGIDSignInErrorDomain,
                   (error as NSError).code == GIDSignInError.canceled.rawValue {
                    self?.state.send(.error(error: GoogleAuthError.sheetDismissed))
                } else {
                    self?.state.send(.error(error: error))
                }
            }
        }
        
        return state.eraseToAnyPublisher()
    }
    
    // MARK: - Requests
    private func sendLoginRequest(using token: String, email: String? = nil) {
        let request = AuthenticationLoginWithSocialProfileRequest(provider: "google-oauth2", token: token)
        AtheloAPI.Authentication.loginUsingSocialProfile(request: request)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.state.send(.error(error: error))
                }
            } receiveValue: { [weak self] value in
                self?.state.send(.loaded(token: value.tokenData, email: email))
            }.store(in: &cancellables)
    }
    
    private func sendTokenRequest(using config: GIDConfiguration, uiProvider: IdentitySignInWithGoogleUIProvider? = nil) async throws -> (token: String, email: String?) {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                var viewController = uiProvider?.signInWithGooglePresentingViewController
                if viewController == nil {
                    viewController = await AppRouter.current.signInWithGooglePresentingViewController
                }
                
                guard let viewController = viewController else {
                    continuation.resume(throwing: GoogleAuthError.missingPresentingUI)
                    return
                }
                
                DispatchQueue.main.async {
                    GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let token = user?.authentication.accessToken else {
                            continuation.resume(throwing: GoogleAuthError.missingAccessToken)
                            return
                        }
                        
                        continuation.resume(returning: (token, user?.profile?.email))
                    }
                }
            }
        }
    }
}

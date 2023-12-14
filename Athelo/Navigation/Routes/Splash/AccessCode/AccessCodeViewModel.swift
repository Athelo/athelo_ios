//
//  AccessCodeViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Combine
import Foundation

final class AccessCodeViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var route: AppRouter.Root?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Public API
    func checkCode(_ code: String) {
        guard state.value != .loading else {
            return
        }
        
        let codeIsValid = AccessCodeUtility.checkCode(code)
        guard codeIsValid else {
            state.send(.error(error: ModelError.invalidCode))
            return
        }
        
        state.send(.loading)
        
        IdentityUtility.refreshUserDetails()
            .map({ _ in true })
            .replaceError(with: false)
            .map { value -> AppRouter.Root in
                if value {
                    return .home
                } else {
                    if PreferencesStore.hasDisplayedIntro() {
                        return .auth
                    } else {
                        return .intro
                    }
                }
            }
            .first()
            .sink { [weak self] result in
                self?.state.send(result.toViewModelState())
            } receiveValue: { [weak self] value in
                self?.route = value
            }.store(in: &cancellables)
    }
}

// MARK: - Helper extensions
extension AccessCodeViewModel {
    enum ModelError: LocalizedError {
        case invalidCode
        
        var errorDescription: String? {
            switch self {
            case .invalidCode:
                return "error.accesscode.invalid".localized()
            }
        }
    }
}

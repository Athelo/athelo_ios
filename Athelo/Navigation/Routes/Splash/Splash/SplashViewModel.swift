//
//  SplashViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation

final class SplashViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var route: AppRouter.Root?
    
    private var cancellables: [AnyCancellable] = []
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        sink()
    }
    
    // MARK: - Sinks
    private func sink() {
        sinkIntoNetworkMonitor()
    }
    
    private func sinkIntoNetworkMonitor() {
//        NetworkUtility.utility.networkAvailablePublisher
//            .setFailureType(to: Error.self)
//            .filter({ $0 })
//            .flatMap({ _ -> AnyPublisher<DeviceConfigData, Error> in
//                ConstantsStore.deviceConfigDataPublisher()
//            })
//            .first(where: { [weak self] in
//                guard SplashViewModel.evaluateAppVersion(using: $0) else {
//                    self?.message.send(.init(text: "error.invalidappversion".localized(), type: .error))
//                    return false
//                }
//                
//                return true
//            })
//            .flatMap { _ -> AnyPublisher<AppRouter.Root, Never> in
//                if !AccessCodeUtility.codeHasBeenProvided {
//                    return Just<AppRouter.Root>(.accessCode)
//                        .eraseToAnyPublisher()
//                }
//                
//                return IdentityUtility.refreshUserDetails()
//                    .map({ _ in true })
//                    .replaceError(with: false)
//                    .map { value -> AppRouter.Root in
//                        if value {
//                            if IdentityUtility.activeUserRole != nil {
//                                return .home
//                            } else {
//                                return .roleSelection
//                            }
//                        } else {
//                            if PreferencesStore.hasDisplayedIntro() {
//                                return .auth
//                            } else {
//                                return .intro
//                            }
//                        }
//                    }
//                    .eraseToAnyPublisher()
//            }
//            .first()
//            .sink { _ in
//                /* ... */
//            } receiveValue: { [weak self] value in
//                self?.route = value
//            }.store(in: &cancellables)
        IdentityUtility.refreshUserDetails()
            .map({ _ in true })
            .replaceError(with: false)
            .map { value -> AppRouter.Root in
                if value {
                    if IdentityUtility.activeUserRole != nil {
                        return .home
                    } else {
                        return .home
//                        return .roleSelection
                    }
                } else {
                    if PreferencesStore.hasDisplayedIntro() {
                        return .auth
                    } else {
                        return .intro
                    }
                }
            }
            .eraseToAnyPublisher()
            .first()
            .sink { _ in
                /* ... */
            } receiveValue: { [weak self] value in
                self?.route = value
            }.store(in: &cancellables)
    }
    
    // MARK: - Updates
    private static func evaluateAppVersion(using deviceConfigData: DeviceConfigData) -> Bool {
        let buildVersion = Bundle.main.appBuild
        let minSupportedVersion = deviceConfigData.minAppVersion.map({ "\($0)" }).joined(separator: ".")
        let maxSupportedVersion = deviceConfigData.maxAppVersion.map({ "\($0)" }).joined(separator: ".")
        
        return buildVersion.compare(minSupportedVersion, options: .numeric) != .orderedAscending && buildVersion.compare(maxSupportedVersion, options: .numeric) != .orderedDescending
    }
}

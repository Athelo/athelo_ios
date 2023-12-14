//
//  SignUpRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

final class SignUpRouter: AuthenticationNavigationRouter {
    // MARK: - Public API
    @MainActor func navigateToAdditionalInfoForm() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = AdditionalProfileInfoRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = AdditionalProfileInfoViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @MainActor func navigateToEmailLogin(additionalSafeAreaInsets: UIEdgeInsets? = nil) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = LogInRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = LogInViewController.viewController(router: router)
        
        if let additionalSafeAreaInsets = additionalSafeAreaInsets {
            viewController.additionalSafeAreaInsets = additionalSafeAreaInsets
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @MainActor func navigateToEmailSignup(additionalSafeAreaInsets: UIEdgeInsets? = nil) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = SignUpWithEmailRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = SignUpWithEmailViewController.viewController(router: router)
        
        if let additionalSafeAreaInsets = additionalSafeAreaInsets {
            viewController.additionalSafeAreaInsets = additionalSafeAreaInsets
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

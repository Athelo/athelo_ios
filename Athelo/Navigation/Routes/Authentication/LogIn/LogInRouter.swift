//
//  AuthenticationLogInRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

final class LogInRouter: AuthenticationNavigationRouter {
    // MARK: - Public API
    func navigateToAdditionalInfoForm() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = AdditionalProfileInfoRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = AdditionalProfileInfoViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToHome() {
        Task {
            await AppRouter.current.exchangeRoot(.home)
        }
    }
    
    func navigateToPasswordReset(with configurationData: ForgotPasswordViewController.ConfigurationData, additionalSafeAreaInsets: UIEdgeInsets? = nil) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = ForgotPasswordRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = ForgotPasswordViewController.viewController(configurationData: configurationData, router: router)
        
        if let additionalSafeAreaInsets = additionalSafeAreaInsets {
            viewController.additionalSafeAreaInsets = additionalSafeAreaInsets
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

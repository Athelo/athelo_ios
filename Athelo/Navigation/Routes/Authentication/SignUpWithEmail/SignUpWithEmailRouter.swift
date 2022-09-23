//
//  SignUpWithEmailRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import UIKit

final class SignUpWithEmailRouter: AuthenticationNavigationRouter {
    // MARK: - Public API
    func navigateToAdditionalInfoForm() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = AdditionalProfileInfoRouter(navigationController: navigationController, updateEventsSubject: authenticationUpdateEventsSubject)
        let viewController = AdditionalProfileInfoViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

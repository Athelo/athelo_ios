//
//  PatientRoleRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation
import UIKit

final class PatientRoleRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    @MainActor func navigateToCaregiverInvitationForm() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = InviteCaregiverRouter(navigationController: navigationController)
        let viewController = InviteCaregiverViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @MainActor func navigateOnRoleConfirmation(with targetRoute: AppRouter.Root = .home) {
        if AppRouter.current.root == .home {
            guard let navigationController else {
                fatalError("Missing \(UINavigationController.self) instance.")
            }
            
            UIView.transition(with: AppRouter.current.window, duration: 0.25, options: [.transitionCrossDissolve]) {
                navigationController.popToRootViewController(animated: false)
                AppRouter.current.switchHomeTab(.home)
            }
        } else {
            AppRouter.current.exchangeRoot(targetRoute)
        }
    }
}

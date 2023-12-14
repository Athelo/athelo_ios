//
//  CaregiverRoleRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation
import UIKit

final class CaregiverRoleRouter: InvitationCodeRouterProtocol {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let invitationCodeUpdateEventsSubject: InvitationCodeUpdateEventsSubject
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.invitationCodeUpdateEventsSubject = InvitationCodeUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, eventsSubject: InvitationCodeUpdateEventsSubject) {
        self.navigationController = navigationController
        self.invitationCodeUpdateEventsSubject = eventsSubject
    }
    
    // MARK: - Public API
    @MainActor func navigateOnRoleConfirmation() {
        if AppRouter.current.root == .home {
            guard let navigationController else {
                fatalError("Missing \(UINavigationController.self) instance.")
            }
            
            UIView.transition(with: AppRouter.current.window, duration: 0.25, options: [.transitionCrossDissolve]) {
                navigationController.popToRootViewController(animated: false)
                AppRouter.current.switchHomeTab(.home)
            }
        } else {
            AppRouter.current.exchangeRoot(.home)
        }
    }
    
    @MainActor func navigateToInvitationCodeInput() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = InvitationCodeRouter(navigationController: navigationController, eventsSubject: invitationCodeUpdateEventsSubject)
        let viewController = InvitationCodeViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

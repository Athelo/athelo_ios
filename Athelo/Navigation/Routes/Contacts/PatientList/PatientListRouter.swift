//
//  PatientListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation
import UIKit

final class PatientListRouter: InvitationCodeRouterProtocol {
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
    @MainActor func navigateToInvitationCodeInput() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = InvitationCodeRouter(navigationController: navigationController, eventsSubject: invitationCodeUpdateEventsSubject)
        let viewController = InvitationCodeViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @MainActor func navigateToChatRoom(with contact: ContactData) {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let configurationData = CommunityChatViewController.ConfigurationData(dataType: nil, identityData: .data(contact))
        let router = CommunityChatRouter(navigationController: navigationController)
        
        let viewController = CommunityChatViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

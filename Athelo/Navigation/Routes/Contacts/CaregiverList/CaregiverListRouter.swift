//
//  CaregiverListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation
import UIKit

final class CaregiverListRouter: InviteCaregiverRouterProtocol {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let inviteCaregiverUpdateEventsSubject: InviteCaregiverUpdateEventsSubject
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.inviteCaregiverUpdateEventsSubject = InviteCaregiverUpdateEventsSubject()
    }
    
    init(navigationController: UINavigationController, eventsSubject: InviteCaregiverUpdateEventsSubject) {
        self.navigationController = navigationController
        self.inviteCaregiverUpdateEventsSubject = eventsSubject
    }
    
    // MARK: - Public API
    @MainActor func navigateToCaregiverInvitationForm() {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = InviteCaregiverRouter(navigationController: navigationController, eventsSubject: inviteCaregiverUpdateEventsSubject)
        let viewController = InviteCaregiverViewController.viewController(router: router)
        
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

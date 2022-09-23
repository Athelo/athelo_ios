//
//  MenuOption+Routing.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Foundation
import UIKit

extension MenuOption {
    func viewController(for navigationController: UINavigationController) -> UIViewController? {
        switch self {
        case .myProfile:
            let router = MyProfileRouter(navigationController: navigationController)
            let viewController = MyProfileViewController.viewController(router: router)
            
            return viewController
        case .messages:
            break
        case .mySymptoms:
            let router = SymptomListRouter(navigationController: navigationController)
            let viewController = SymptomListViewController.viewController(router: router)
            
            return viewController
        case .myCaregivers:
            break
        case .inviteACaregiver:
            break
        case .settings:
            let router = SettingsRouter(navigationController: navigationController)
            let viewController = SettingsViewController.viewController(router: router)
            
            return viewController
        case .connectSmartWatch:
            let router = ConnectDeviceRouter(navigationController: navigationController)
            let viewController = ConnectDeviceViewController.viewController(configurationData: .init(deviceType: .fitbit), router: router)
            
            return viewController
        case .askAthelo:
            let router = AskAtheloRouter(navigationController: navigationController)
            let viewController = AskAtheloViewController.viewController(router: router)
            
            return viewController
        case .sendFeedback:
            let router = FeedbackRouter(navigationController: navigationController)
            let viewController = FeedbackViewController.viewController(router: router)
            
            return viewController
        }
        
        return nil
    }
}

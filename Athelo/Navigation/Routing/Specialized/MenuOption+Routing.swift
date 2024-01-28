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
//        case .messages:
//            let router = PrivateChatListRouter(navigationController: navigationController)
//            let viewController = PrivateChatListViewController.viewController(router: router)
//            
//            return viewController
        case .mySymptoms:
            let router = SymptomListRouter(navigationController: navigationController)
            let viewController = SymptomListViewController.viewController(router: router)
            
            return viewController
//        case .myCaregivers:
//            let router = CaregiverListRouter(navigationController: navigationController)
//            let viewController = CaregiverListViewController.viewController(router: router)
//            
//            return viewController
//        case .myWards:
//            let router = PatientListRouter(navigationController: navigationController)
//            let viewController = PatientListViewController.viewController(router: router)
//            
//            return viewController
        case .settings:
            let router = SettingsRouter(navigationController: navigationController)
            let viewController = SettingsViewController.viewController(router: router)
            
            return viewController
//        case .connectSmartWatch:
//            let router = ConnectDeviceRouter(navigationController: navigationController)
//            let viewController = ConnectDeviceViewController.viewController(configurationData: .init(deviceType: .fitbit), router: router)
//            
//            return viewController
        case .askAthelo:
            let router = FeedbackRouter(navigationController: navigationController)
            let viewController = FeedbackViewController.viewController(router: router)
            
            return viewController
//        case .sendFeedback:
//            let router = FeedbackRouter(navigationController: navigationController)
//            let viewController = FeedbackViewController.viewController(router: router)
//            
//            return viewController
        }
    }
}

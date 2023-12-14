//
//  SelectRoleRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/03/2023.
//

import Foundation
import UIKit

final class SelectRoleRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    @MainActor func navigateToRoleDetails(using role: UserRole, configurationData: SelectRoleViewController.ConfigurationData? = nil) {
        guard let navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        switch role {
        case .caregiver:
            let router: CaregiverRoleRouter = .init(navigationController: navigationController)
            let viewController: CaregiverRoleViewController = .viewController(router: router)
            
            navigationController.pushViewController(viewController, animated: true)
        case .patient:
            let expectsDeviceSync = configurationData?.expectsDeviceSync == true
            
            let configurationData = PatientRoleViewController.ConfigurationData(targetRoute: expectsDeviceSync ? .sync : .home)
            let router = PatientRoleRouter(navigationController: navigationController)
            let viewController = PatientRoleViewController.viewController(configurationData: configurationData, router: router)
            
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

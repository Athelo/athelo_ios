//
//  SettingsRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Foundation
import UIKit

final class SettingsRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToLegal(using configurationData: LegalConfigurationData) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = LegalRouter(navigationController: navigationController)
        let viewController = LegalViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToPersonalInformation() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = EditProfileRouter(navigationController: navigationController)
        let viewControlller = EditProfileViewController.viewController(router: router)
        
        navigationController.pushViewController(viewControlller, animated: true)
    }
}

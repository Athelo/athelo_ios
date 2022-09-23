//
//  MyProfileRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Foundation
import UIKit

final class MyProfileRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initilization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToChangePasswordForm() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = ChangePasswordRouter(navigationController: navigationController)
        let viewController = ChangePasswordViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToDeviceDetails() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = MyDeviceRouter(navigationController: navigationController)
        let viewController = MyDeviceViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToEditProfileForm() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = EditProfileRouter(navigationController: navigationController)
        let viewController = EditProfileViewController.viewController(configurationData: .init(locksEditMode: true), router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToSymptomList() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = SymptomListRouter(navigationController: navigationController)
        let viewController = SymptomListViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToSymptomRegistration() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = RegisterSymptomsRouter(navigationController: navigationController)
        let viewController = RegisterSymptomsViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

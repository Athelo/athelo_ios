//
//  SymptomListRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation
import UIKit

final class SymptomListRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToSymptomDescription(using configurationData: SymptomDescriptionConfigurationData) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = SymptomDescriptionRouter(navigationController: navigationController)
        let viewController = SymptomDescriptionViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

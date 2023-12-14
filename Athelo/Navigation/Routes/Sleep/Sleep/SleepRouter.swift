//
//  SleepRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation
import UIKit

final class SleepRouter: Router, UserProfileRoutable {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToArticleDetails(using configurationData: ModelConfigurationData<NewsData>) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = NewsDetailsRouter(navigationController: navigationController)
        let viewController = NewsDetailsViewController.viewController(secondaryConfigurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func navigateToSleepSummary() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = SleepSummaryRouter(navigationController: navigationController)
        let viewController = SleepSummaryViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

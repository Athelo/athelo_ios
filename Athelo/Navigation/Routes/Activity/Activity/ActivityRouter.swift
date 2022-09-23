//
//  ActivityRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation
import UIKit

final class ActvityRouter: Router, UserProfileRoutable {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToActivitySummary(using activityType: ActivityType) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }

        let router = ActivitySummaryRouter(navigationController: navigationController)
        let viewController = ActivitySummaryViewController.viewController(configurationData: activityType, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

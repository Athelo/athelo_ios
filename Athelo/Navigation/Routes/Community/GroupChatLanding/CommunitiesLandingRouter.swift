//
//  GroupChatLandingRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import Foundation
import UIKit

final class CommunitiesLandingRouter: Router, UserProfileRoutable {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToCommunitiesList() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = CommunitiesListRouter(navigationController: navigationController)
        let viewController = CommunitiesListViewController.viewController(router: router)
        
        var targetStack = navigationController.viewControllers
        
        targetStack.removeAll(where: { $0 is CommunitiesLandingViewController })
        targetStack.append(viewController)
        
        navigationController.setViewControllers(targetStack, animated: true)
    }
}

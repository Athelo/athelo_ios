//
//  AskAtheloRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import Foundation
import UIKit

final class AskAtheloRouter: Router, WebContentRouter {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToFeedback() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = FeedbackRouter(navigationController: navigationController)
        let viewController = FeedbackViewController.viewController(configurationData: .init(shouldPreselectQuestionCategory: true), router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

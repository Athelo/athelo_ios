//
//  HomeRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 10/06/2022.
//

import Foundation
import UIKit

final class HomeRouter: Router, UserProfileRoutable, WebContentRouter {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateUsingPrompt(_ navigationPrompt: HomeViewModel.RecommendationPrompt) {
        switch navigationPrompt {
        case .chatWithCommunity:
            Task {
                await AppRouter.current.switchHomeTab(.community)
            }
        case .readArticles:
            Task {
                await AppRouter.current.switchHomeTab(.news)
            }
        case .connectDevice:
            guard let navigationController = navigationController else {
                fatalError("Missing \(UINavigationController.self) instance.")
            }
            
            let router = ConnectDeviceRouter(navigationController: navigationController)
            let viewController = ConnectDeviceViewController.viewController(configurationData: .init(deviceType: .fitbit), router: router)
            
            navigationController.pushViewController(viewController, animated: true)
        case .registerFeelings, .updateFeelings:
            guard let navigationController = navigationController else {
                fatalError("Missing \(UINavigationController.self) instance.")
            }
            
            let router = RegisterSymptomsRouter(navigationController: navigationController)
            let viewController = RegisterSymptomsViewController.viewController(router: router)
            
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

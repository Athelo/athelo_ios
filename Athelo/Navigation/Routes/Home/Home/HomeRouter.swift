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
    @MainActor func navigateUsingInteractableItem(_ item: HomeViewModel.InteractableKey) {
//        switch item {
//        case .recommendationCaregiverActivity:
//            AppRouter.current.switchHomeTab(.activity)
//        case .recommendationCaregiverSleep:
//            AppRouter.current.switchHomeTab(.sleep)
//        }
        
        NSLog("Switch time")
    }
    
    @MainActor func navigateUsingPrompt(_ navigationPrompt: HomeViewModel.RecommendationPrompt) {
        switch navigationPrompt {
        case .chatWithCommunity:
            AppRouter.current.switchHomeTab(.community)
//        case .checkActivityLevels:
//            AppRouter.current.switchHomeTab(.activity)
//        case .checkSleepLevels:
//            AppRouter.current.switchHomeTab(.sleep)
        case .readArticles:
            AppRouter.current.switchHomeTab(.news)
//        case .connectDevice:
//            guard let navigationController = navigationController else {
//                fatalError("Missing \(UINavigationController.self) instance.")
//            }
//            
//            let router = ConnectDeviceRouter(navigationController: navigationController)
//            let viewController = ConnectDeviceViewController.viewController(configurationData: .init(deviceType: .fitbit), router: router)
//            
//            navigationController.pushViewController(viewController, animated: true)
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

//
//  ConnectDeviceRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation
import UIKit

final class ConnectDeviceRouter: Router, UserProfileRoutable, WebContentRouter {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    @MainActor func navigateToActivity() {
        if AppRouter.current.root == .home {
            let animateTransition = AppRouter.current.homeTab == .activity
            
            _ = navigationController?.popViewController(animated: animateTransition)
        } else {
            AppRouter.current.exchangeRoot(.home)
        }
        
        AppRouter.current.switchHomeTab(.activity)
    }
}

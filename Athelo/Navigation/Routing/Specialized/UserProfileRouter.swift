//
//  UserProfileRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import Foundation
import UIKit

protocol UserProfileRoutable: RouterProtocol {
    func navigateToUserProfile()
}

extension UserProfileRoutable where Self: Router {
    func navigateToUserProfile() {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }

        let router = MyProfileRouter(navigationController: navigationController)
        let viewController = MyProfileViewController.viewController(router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

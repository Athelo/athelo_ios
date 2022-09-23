//
//  NoWatchRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation
import UIKit

final class NoWatchRouter: Router, WebContentRouter {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToDeviceConnection(for deviceType: DeviceType) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = ConnectDeviceRouter(navigationController: navigationController)
        let viewController = ConnectDeviceViewController.viewController(configurationData: .init(deviceType: .fitbit), router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

//
//  SymptomDescriptionRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation
import UIKit

final class SymptomDescriptionRouter: Router {
    // MARK: - Propperties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToSymptomChronology(using configurationData: ModelConfigurationListData<SymptomData>) {
        guard let navigationController = navigationController else {
            fatalError("Missing \(UINavigationController.self) instance.")
        }
        
        let router = SymptomChronologyRouter(navigationController: navigationController)
        let viewController = SymptomChronologyViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

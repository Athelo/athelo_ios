//
//  RegisterSymptomsRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Combine
import Foundation
import UIKit

enum RegisterSymptomUpdateEvent {
    case symptomDataUpdated(SymptomDaySummaryData)
    
    var symptomSummaryData: SymptomDaySummaryData? {
        switch self {
        case .symptomDataUpdated(let data):
            return data
        }
    }
}

final class RegisterSymptomsRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    let registerSymptomEventsSubject = PassthroughSubject<RegisterSymptomUpdateEvent, Never>()
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Public API
    func navigateToSymptomDescription(using configurationData: SymptomDescriptionConfigurationData) {
        guard let navigationController = navigationController else {
            return
        }

        let router = SymptomDescriptionRouter(navigationController: navigationController)
        let viewController = SymptomDescriptionViewController.viewController(configurationData: configurationData, router: router)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

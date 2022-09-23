//
//  FeedbackRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Foundation
import UIKit

final class FeedbackRouter: Router {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

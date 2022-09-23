//
//  SymptomChronologyRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import Foundation
import UIKit

final class SymptomChronologyRouter: Router {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


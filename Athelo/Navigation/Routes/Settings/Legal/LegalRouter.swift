//
//  LegalRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Foundation
import UIKit

final class LegalRouter: Router, WebContentRouter {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

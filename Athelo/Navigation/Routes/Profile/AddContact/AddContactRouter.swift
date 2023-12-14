//
//  AddContactRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/09/2022.
//

import Foundation
import UIKit

final class AddContactRouter: Router {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

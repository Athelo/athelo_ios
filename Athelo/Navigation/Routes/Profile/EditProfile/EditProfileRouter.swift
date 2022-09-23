//
//  EditProfileRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/06/2022.
//

import Foundation
import UIKit

final class EditProfileRouter: Router, ImagePickingRoutable {
    // MARK: - Properties
    weak var navigationController: UINavigationController?
    
    // MARK: - Initialization
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

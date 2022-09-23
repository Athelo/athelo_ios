//
//  MyDeviceRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 25/07/2022.
//

import Foundation
import UIKit

final class MyDeviceRouter: Router {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

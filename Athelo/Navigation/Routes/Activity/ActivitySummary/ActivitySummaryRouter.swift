//
//  ActivitySummaryRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation
import SwiftUI

final class ActivitySummaryRouter: Router {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

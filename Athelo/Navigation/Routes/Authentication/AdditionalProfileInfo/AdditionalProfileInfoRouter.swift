//
//  AdditionalProfileInfoRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import UIKit

final class AdditionalProfileInfoRouter: AuthenticationNavigationRouter {
    func navigateToSync() {
        Task {
            await AppRouter.current.exchangeRoot(.sync)
        }
    }
}

//
//  SplashRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation
import UIKit

final class SplashRouter: RouterProtocol {    
    // MARK: - Public API
    func resolveRoute(_ route: AppRouter.Root) {
        Task {
            // Small delay to avoid unbalanced calls on root switch.
            try await Task.sleep(nanoseconds: UInt64(powf(10, 8)))
            await AppRouter.current.exchangeRoot(route)
        }
    }
}

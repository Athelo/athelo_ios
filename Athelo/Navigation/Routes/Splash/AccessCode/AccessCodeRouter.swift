//
//  AccessCodeRouter.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Foundation

final class AccessCodeRouter: RouterProtocol {
    // MARK: - Public API
    @MainActor
    func resolveRoute(_ route: AppRouter.Root) {
        AppRouter.current.exchangeRoot(route)
    }
}

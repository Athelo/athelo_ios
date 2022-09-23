//
//  Array+Cancellables.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Combine
import Foundation

extension Array where Element == AnyCancellable {
    /// Cancels all owned cancellable items and clears own contents afterwards.
    mutating func cancelAndClear() {
        forEach {
            $0.cancel()
        }
        removeAll()
    }
}

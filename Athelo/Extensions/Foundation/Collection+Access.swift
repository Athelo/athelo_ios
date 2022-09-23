//
//  Collection+Access.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

extension Collection {
    /// Searches for first item of given type.
    ///
    /// - Parameter type: Type of object to be found.
    ///
    /// - Returns: First instance of given type, if any.
    func first<T>(ofType type: T.Type) -> T? {
        first(where: { $0 is T }) as? T
    }

    /// Searches for last item of given type.
    ///
    /// - Parameter type: Type of object to be found.
    ///
    /// - Returns: Last instance of given type, if any.
    func last<T>(ofType type: T.Type) -> T? {
        reversed().first(where: { $0 is T }) as? T
    }

    subscript(safe index: Self.Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

//
//  Publisher+ViewModelState.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/06/2022.
//

import Combine
import Foundation

extension Publisher where Output == ViewModelState, Failure == Never {
    /// Passes only errors with implicit type.
    func toError<E: Error>() -> AnyPublisher<E, Never> {
        compactMap({ val -> E? in
            if case .error(let error) = val {
                return error as? E
            } else {
                return nil
            }
        }).eraseToAnyPublisher()
    }

    /// Passes only errors with expected type.
    func toError<E: Error>(of type: E.Type) -> AnyPublisher<E, Never> {
        toError()
    }
}

//
//  Completion+ViewModelState.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 07/06/2022.
//

import Combine
import Foundation

extension Subscribers.Completion {
    func toViewModelState() -> ViewModelState {
        switch self {
        case .failure(let error):
            return .error(error: error)
        case .finished:
            return .loaded
        }
    }
}

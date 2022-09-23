//
//  ViewModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Combine
import Foundation

enum ViewModelState {
    /// Indicates that an error occurred during data refreshing.
    case error(error: Error)
    /// Indicates that no data refreshing has occurred during view model lifecycle.
    case initial
    /// Indicates that new data have appeared.
    case loaded
    /// Indicates that new data are being fetched.
    case loading


    /// Describes if state can be interpreted as an new data event, erroneous or not.
    var notifiesAboutDataUpdate: Bool {
        switch self {
        case .error, .loaded:
            return true
        case .initial, .loading:
            return false
        }
    }
}

extension ViewModelState: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch((lhs, rhs)) {
        case (.error, .error):
            return true
        case (.initial, .initial):
            return true
        case (.loaded, .loaded):
            return true
        case (.loading, .loading):
            return true
        default:
            break
        }

        return false
    }
}

class BaseViewModel {
    // MARK: - Properties
    let message = CurrentValueSubject<InfoMessageData?, Never>(nil)
    let state = CurrentValueSubject<ViewModelState, Never>(.initial)
}

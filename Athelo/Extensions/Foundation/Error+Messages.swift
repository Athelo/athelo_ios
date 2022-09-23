//
//  Error+Messages.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 19/07/2022.
//

import Foundation

extension Error {
    func toInfoMessageData() -> InfoMessageData {
        if case .httpError(_, let message) = self as? APIError {
            return .init(text: message.combinedErrorMessage() ?? "error.unknown".localized(), type: .error)
        } else {
            return .init(text: localizedDescription, type: .error)
        }
    }
}

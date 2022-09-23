//
//  Validator.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation

enum ValidationResult<ErrorType> {
    case failed(errors: [ErrorType])
    case validated

    var errors: [ErrorType]? {
        switch self {
        case .failed(let errors):
            return errors
        case .validated:
            return nil
        }
    }

    var isValid: Bool {
        switch self {
        case .failed:
            return false
        case .validated:
            return true
        }
    }
}

protocol Validator {
    associatedtype ValidatorErrorType: Error
    associatedtype ValidatedValueType

    static func validate(_ value: ValidatedValueType) -> ValidationResult<ValidatorErrorType>
}

//
//  PasswordsValidator.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation

enum PasswordsValidatorError: LocalizedError {
    case invalidPassword(errors: [PasswordValidatorError])
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .invalidPassword(let errors):
            return errors.map({ $0.localizedDescription }).joined(separator: "\n")
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
}

struct PasswordsValidatorData {
    let primaryPassword: String?
    let secondaryPassword: String?
    let checkPasswordsOneByOne: Bool
    
    init(primaryPassword: String?, secondaryPassword: String?, checkPasswordsOneByOne: Bool = true) {
        self.primaryPassword = primaryPassword
        self.secondaryPassword = secondaryPassword
        self.checkPasswordsOneByOne = checkPasswordsOneByOne
    }
}

final class PasswordsValidator: Validator {
    typealias ValidatorErrorType = PasswordsValidatorError
    typealias ValidatedValueType = PasswordsValidatorData

    static func validate(_ value: PasswordsValidatorData) -> ValidationResult<PasswordsValidatorError> {
        var errors: [PasswordsValidatorError] = []

        if value.checkPasswordsOneByOne {
            let validationErrors = Array(Set([value.primaryPassword, value.secondaryPassword].compactMap({ PasswordValidator.validate($0).errors }).flatMap({ $0 })))
            if !validationErrors.isEmpty {
                errors.append(.invalidPassword(errors: validationErrors))
            }
        }

        if value.primaryPassword != value.secondaryPassword {
            errors.append(.passwordsDoNotMatch)
        }

        return errors.isEmpty ? .validated : .failed(errors: errors)
    }
}

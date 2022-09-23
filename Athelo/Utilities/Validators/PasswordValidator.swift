//
//  PasswordValidator.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation

enum PasswordValidatorError: LocalizedError {
    case passwordTooShort
    case passwordTooWeak

    var errorDescription: String? {
        switch self {
        case .passwordTooShort:
            return "Password is too short. It has to contain at least 8 characters."
        case .passwordTooWeak:
            return "Password is too weak. It should contain at least one small letter, one large letter, one number and one special symbol."
        }
    }
}

final class PasswordValidator: Validator {
    typealias ValidatorErrorType = PasswordValidatorError
    typealias ValidatedValueType = String?

    static func validate(_ value: String?) -> ValidationResult<PasswordValidatorError> {
        guard let password = value, !password.isEmpty else {
            return .failed(errors: [.passwordTooShort])
        }

        var errors: [PasswordValidatorError] = []
        if password.count < 8 {
            errors.append(.passwordTooShort)
        }

        // NOTE: for now passwords checks are weakened - until error UI on registration flow is fixed.

        return errors.isEmpty ? .validated : .failed(errors: errors)

//        let patterns = ["[A-Z]+", "[a-z]+", "[0-9]+", "[^A-Za-z0-9]+"]
//        let isWeak = patterns.first(where: { password.range(of: $0, options: .regularExpression) == nil })?.first != nil
//
//        if isWeak {
//            errors.append(.passwordTooWeak)
//        }
//
//        return errors.isEmpty ? .validated : .failed(errors: errors)
    }
}



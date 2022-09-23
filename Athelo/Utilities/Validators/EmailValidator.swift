//
//  EmailValidator.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation

enum EmailValidatorError: LocalizedError {
    case invalidFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Provided email address is in invalid format."
        }
    }
}

final class EmailValidator: Validator {
    typealias ValidatorErrorType = EmailValidatorError
    typealias ValidatedValueType = String?

    static func validate(_ value: String?) -> ValidationResult<EmailValidatorError> {
        guard let email = value, !email.isEmpty else {
            return .failed(errors: [.invalidFormat])
        }

        let loosePattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let strictPattern = """
        (?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])
        """

        let isValid = [loosePattern, strictPattern].compactMap({ email.range(of: $0, options: .regularExpression) }).count == 2

        return isValid ? .validated : .failed(errors: [.invalidFormat])
    }
}

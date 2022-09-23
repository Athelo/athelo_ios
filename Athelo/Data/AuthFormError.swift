//
//  AuthFormError.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Foundation

enum AuthFormError {
    case confirmPassword(String)
    case email(String)
    case oldPassword(String)
    case password(String)
    
    static func formErrors(from error: APIError) -> [AuthFormError]? {
        guard case .httpError(_, let message) = error else {
            return nil
        }

        var errors: [AuthFormError] = []
        
        if let confirmPasswordError = message.errorMessage(for: "password2") ?? message.errorMessage(for: "new_password2") {
            errors.append(.confirmPassword(confirmPasswordError))
        }
        if let usernameError = message.errorMessage(for: "username") ?? message.errorMessage(for: "email") {
            errors.append(.email(usernameError))
        }
        if let oldPasswordError = message.errorMessage(for: "old_password") {
            errors.append(.oldPassword(oldPasswordError))
        }
        if let passwordError = message.errorMessage(for: "password1") ?? message.errorMessage(for: "password") ?? message.errorMessage(for: "new_password1") {
            errors.append(.password(passwordError))
        }

        guard !errors.isEmpty else {
            return nil
        }
        
        return errors
    }
}

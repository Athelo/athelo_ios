//
//  IdentityAuthenticationMethod.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import Foundation

struct IdentityAuthenticationMethod: Decodable {
    enum LoginType: String, Decodable {
        case native = "I2A_IDENTITY"
        case social = "SOCIAL_IDENTITY"
    }
    
    let email: String?
    let loginType: LoginType
    let provider: String?
    
    private enum CodingKeys: String, CodingKey {
        case email, provider
        case loginType = "login_type"
    }
}

extension Collection where Element == IdentityAuthenticationMethod {
    func containsNativeAuthData() -> Bool {
        contains(where: { $0.loginType == .native })
    }
}

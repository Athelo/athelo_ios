//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation

public struct IdentityTokenDataWrapper: Codable {
    public let tokenData: IdentityTokenData

    private enum CodingKeys: String, CodingKey {
        case tokenData = "token_data"
    }
}

public struct IdentityTokenData: Codable {
    let accessToken: String
    let expiresIn: Double
    let refreshToken: String
    let scope: String
    let tokenType: String

    private enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

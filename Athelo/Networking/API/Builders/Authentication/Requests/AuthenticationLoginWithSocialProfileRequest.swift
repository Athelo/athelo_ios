import Foundation

public struct AuthenticationLoginWithSocialProfileRequest: APIRequest {
    let provider: String
    let token: String
    
    public init(provider: String, token: String) {
        self.provider = provider
        self.token = token
    }
    
    public var parameters: [String: Any]? {
        ["third_party_access_token_source": provider,
         "third_party_access_token": token]
    }
}

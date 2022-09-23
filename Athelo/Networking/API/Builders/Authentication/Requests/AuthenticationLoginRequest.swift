import Foundation

public struct AuthenticationLoginRequest: APIRequest {
    let email: String
    let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    public var parameters: [String : Any]? {
        ["email": email,
         "password": password]
    }
}

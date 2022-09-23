import Foundation

public struct AuthenticationRegisterRequest: APIRequest {
    let email: String
    let password: String
    let repeatedPassword: String
    
    public init(email: String, password: String, repeatedPassword: String) {
        self.email = email
        self.password = password
        self.repeatedPassword = repeatedPassword
    }
    
    public var parameters: [String : Any]? {
        ["email": email,
         "password1": password,
         "password2": repeatedPassword]
    }
}

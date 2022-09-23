import Foundation

public struct PasswordResetRequest: APIRequest {
    public enum RequestType {
        case code
        case link
    }
    
    let email: String
    let type: RequestType
    
    public init(email: String, type: PasswordResetRequest.RequestType) {
        self.email = email
        self.type = type
    }
    
    public var parameters: [String : Any]? {
        ["email": email]
    }
}

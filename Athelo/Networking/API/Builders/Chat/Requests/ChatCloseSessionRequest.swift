import Foundation

public struct ChatCloseSessionRequest: APIRequest {
    let token: String
    
    public init(token: String) {
        self.token = token
    }
    
    public var parameters: [String : Any]? {
        ["token": token]
    }
}

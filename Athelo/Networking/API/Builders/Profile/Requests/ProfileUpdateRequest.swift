import Foundation

public struct ProfileUpdateRequest: APIRequest {
    let userID: Int
    let params: [String: Any]

    public init(userID: Int, params: [String: Any]) {
        self.userID = userID
        self.params = params
    }
    
    public var parameters: [String : Any]? {
        params
    }
}

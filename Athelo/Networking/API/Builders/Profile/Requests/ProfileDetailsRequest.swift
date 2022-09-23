import Foundation

public struct ProfileDetailsRequest: APIRequest {
    let userID: Int

    public init(userID: Int) {
        self.userID = userID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

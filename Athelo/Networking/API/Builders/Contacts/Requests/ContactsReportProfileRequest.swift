import Foundation

public struct ContactsReportProfileRequest: APIRequest {
    let message: String
    let userID: Int

    public init(userID: Int, message: String) {
        self.message = message
        self.userID = userID
    }
    
    public var parameters: [String : Any]? {
        ["message": message]
    }
}

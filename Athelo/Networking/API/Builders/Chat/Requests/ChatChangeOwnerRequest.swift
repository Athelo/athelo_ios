import Foundation

public struct ChatChangeOwnerRequest: APIRequest {
    let conversationID: Int
    let userProfileID: Int
    
    public init(conversationID: Int, userProfileID: Int) {
        self.conversationID = conversationID
        self.userProfileID = userProfileID
    }
    
    public var parameters: [String : Any]? {
        ["user_profile_id": userProfileID]
    }
}

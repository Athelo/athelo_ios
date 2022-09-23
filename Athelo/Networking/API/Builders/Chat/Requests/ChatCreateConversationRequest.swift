import Foundation

public struct ChatCreateConversationRequest: APIRequest {
    let userProfileID: Int
    
    public init(userProfileID: Int) {
        self.userProfileID = userProfileID
    }
    
    public var parameters: [String : Any]? {
        ["user_profile_id": userProfileID]
    }
}

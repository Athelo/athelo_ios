import Foundation

public struct ChatAddUsersRequest: APIRequest {
    let conversationID: Int
    let userProfileIDs: [Int]
    
    public init(conversationID: Int, userProfileIDs: [Int]) {
        self.conversationID = conversationID
        self.userProfileIDs = userProfileIDs
    }
    
    public var parameters: [String : Any]? {
        ["user_profile_ids": userProfileIDs]
    }
}

import Foundation

public struct ChatCreateGroupConversationRequest: APIRequest {
    let conversationName: String
    let userProfileIDs: [Int]
    
    public init(conversationName: String, userProfileIDs: [Int]) {
        self.conversationName = conversationName
        self.userProfileIDs = userProfileIDs
    }
    
    public var parameters: [String : Any]? {
        ["name": conversationName,
         "user_profile_ids": userProfileIDs]
    }
}

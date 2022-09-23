import Foundation

public struct ChatGroupConversationDetailsRequest: APIRequest {
    let conversationID: Int
    
    public init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

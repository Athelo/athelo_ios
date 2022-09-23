import Foundation

public struct ChatConversationDetailsRequest: APIRequest {
    let conversationID: Int
    
    public init(conversationID: Int) {
        self.conversationID = conversationID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

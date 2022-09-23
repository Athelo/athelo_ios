import Foundation

public struct ChatLeaveGroupConversationRequest: APIRequest {
    let chatRoomID: Int
    
    public init(chatRoomID: Int) {
        self.chatRoomID = chatRoomID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

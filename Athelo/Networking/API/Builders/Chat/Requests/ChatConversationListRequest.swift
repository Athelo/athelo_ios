import Foundation

public struct ChatConversationListRequest: APIRequest {
    let chatRoomIDs: [String]?

    public init(chatRoomIDs: [String]? = nil) {
        self.chatRoomIDs = chatRoomIDs
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

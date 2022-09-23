import Foundation

public struct ChatGroupConversationListRequest: APIRequest {
    let chatRoomIDs: [String]?
    let chatRoomTypes: [Int]?
    let isPublic: Bool?
    let userID: Int?

    public init(chatRoomIDs: [String]? = nil, chatRoomTypes: [Int]? = nil, isPublic: Bool? = nil, userID: Int? = nil) {
        self.chatRoomIDs = chatRoomIDs
        self.chatRoomTypes = chatRoomTypes
        self.isPublic = isPublic
        self.userID = userID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

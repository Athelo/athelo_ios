import Foundation

public struct ContactsRemoveFriendRequest: APIRequest {
    let relationID: Int
    
    public init(relationID: Int) {
        self.relationID = relationID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

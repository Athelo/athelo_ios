import Foundation

public struct ContactsSearchRequest: APIRequest {
    let isFriend: Bool?
    let query: String
    let profileTagIDs: [Int]?

    public init(query: String, isFriend: Bool? = nil, profileTagIDs: [Int]? = nil) {
        self.isFriend = isFriend
        self.query = query
        self.profileTagIDs = profileTagIDs
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

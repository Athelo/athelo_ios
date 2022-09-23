import Foundation

public struct PostListRequest: APIRequest {
    let categoryIDs: [Int]?
    let eventID: Int?
    let favorite: Bool?
    let pageSize: Int?
    let query: String?

    public init(query: String? = nil, categoryIDs: [Int]? = nil, eventID: Int? = nil, favorite: Bool? = nil, pageSize: Int? = nil) {
        self.categoryIDs = categoryIDs
        self.eventID = eventID
        self.favorite = favorite
        self.pageSize = pageSize
        self.query = query
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

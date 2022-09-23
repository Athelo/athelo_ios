import Foundation

public struct ProfileAddTagsRequest: APIRequest {
    let tagIDs: [Int]
    
    public init(tagIDs: [Int]) {
        self.tagIDs = tagIDs
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        parameters["person_tags_ids"] = tagIDs

        return parameters
    }
}

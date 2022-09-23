import Foundation

public struct TagTreeRequest: APIRequest {
    let categoryID: Int?

    public init(categoryID: Int? = nil) {
        self.categoryID = categoryID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

import Foundation

public struct ChecklistItemDetailsRequest: APIRequest {
    let itemID: Int
    
    public init(itemID: Int) {
        self.itemID = itemID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

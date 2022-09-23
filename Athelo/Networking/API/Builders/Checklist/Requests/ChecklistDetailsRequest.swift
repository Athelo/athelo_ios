import Foundation

public struct ChecklistDetailsRequest: APIRequest {
    let checklistID: Int
    
    public init(checklistID: Int) {
        self.checklistID = checklistID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

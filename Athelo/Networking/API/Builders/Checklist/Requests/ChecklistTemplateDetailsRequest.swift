import Foundation

public struct ChecklistTemplateDetailsRequest: APIRequest {
    let checklistTemplateID: Int
    
    public init(checklistTemplateID: Int) {
        self.checklistTemplateID = checklistTemplateID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

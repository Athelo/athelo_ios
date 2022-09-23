import Foundation

public struct ChecklistCreateChecklistRequest: APIRequest {
    let checklistTemplateID: Int
    let keyDate: Date
    
    public init(checklistTemplateID: Int, keyDate: Date) {
        self.checklistTemplateID = checklistTemplateID
        self.keyDate = keyDate
    }
    
    public var parameters: [String : Any]? {
        [
            "check_list_id": checklistTemplateID,
            "key_date": keyDate.toString(.custom("yyyy-MM-dd"))
        ]
    }
}

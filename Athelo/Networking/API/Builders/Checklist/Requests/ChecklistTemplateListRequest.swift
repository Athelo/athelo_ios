import Foundation

public struct ChecklistTemplateListRequest: APIRequest {
    let isStarted: Bool?
    
    public init(isStarted: Bool?) {
        self.isStarted = isStarted
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

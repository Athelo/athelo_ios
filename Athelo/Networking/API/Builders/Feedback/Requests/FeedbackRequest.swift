import Foundation

public struct FeedbackRequest: APIRequest {
    public enum FeedbackType {
        case category(Int)
        case topic(Int)
    }
    
    let message: String
    let type: FeedbackType
    
    public init(message: String, type: FeedbackType) {
        self.message = message
        self.type = type
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [
            "content": message
        ]
        
        switch type {
        case .category(let id):
            params["category"] = id
        case .topic(let id):
            params["topic_id"] = id
        }
        
        return params
    }
}

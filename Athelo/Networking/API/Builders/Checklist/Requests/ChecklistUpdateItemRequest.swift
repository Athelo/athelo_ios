import Foundation

public struct ChecklistUpdateItemRequest: APIRequest {
    let id: Int
    let notes: String?
    let status: Int?

    public init(id: Int, notes: String? = nil, status: Int? = nil) {
        self.id = id
        self.notes = notes
        self.status = status
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        parameters["notes"] = notes
        parameters["status"] = status

        return parameters
    }
}

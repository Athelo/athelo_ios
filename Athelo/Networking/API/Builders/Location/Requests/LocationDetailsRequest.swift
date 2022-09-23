import Foundation

public struct LocationDetailsRequest: APIRequest {
    let id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

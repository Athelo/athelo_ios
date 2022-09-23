import Foundation

public struct ContactsInvitationListRequest: APIRequest {
    public enum RequestType {
        case received
        case sent
    }
    
    let status: Int?
    let type: RequestType

    public init(type: RequestType, status: Int? = nil) {
        self.type = type
        self.status = status
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

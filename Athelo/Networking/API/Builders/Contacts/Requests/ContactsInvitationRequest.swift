import Foundation

public struct ContactsInvitationRequest: APIRequest {
    let invitationID: Int
    
    public init(invitationID: Int) {
        self.invitationID = invitationID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

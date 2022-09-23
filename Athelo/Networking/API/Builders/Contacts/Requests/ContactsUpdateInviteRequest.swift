import Foundation

public struct ContactsUpdateInviteRequest: APIRequest {
    let confirmed: Bool
    let inviteID: Int

    public init(inviteID: Int, confirmed: Bool) {
        self.confirmed = confirmed
        self.inviteID = inviteID
    }
    
    public var parameters: [String : Any]? {
        ["accept": confirmed]
    }
}

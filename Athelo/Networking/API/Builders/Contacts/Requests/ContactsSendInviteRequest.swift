import Foundation

public struct ContactsSendInviteRequest: APIRequest {
    let message: String?
    let profileID: Int

    public init(profileID: Int, message: String? = nil) {
        self.message = message
        self.profileID = profileID
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [
            "receiver_user_profile_id": profileID
        ]

        parameters["message"] = message

        return parameters
    }
}

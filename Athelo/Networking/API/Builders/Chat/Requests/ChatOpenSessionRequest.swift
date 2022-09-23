import Foundation

public struct ChatOpenSessionRequest: APIRequest {
    let deviceID: String
    let fcmToken: String?
    
    public init(deviceID: String, fcmToken: String? = nil) {
        self.deviceID = deviceID
        self.fcmToken = fcmToken
    }
    
    public var parameters: [String : Any]? {
        var params: [String: Any] = [:]
        
        params["device_identifier"] = deviceID
        params["fcm_token"] = fcmToken
        
        return params
    }
}

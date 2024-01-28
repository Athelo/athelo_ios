import Foundation

public struct ProfileCreateRequest: APIRequest {
    let email: String
    let additionalParams: [String : Any]?

    public init(email: String, additionalParams: [String: Any]? = nil) {
        self.email = email

        self.additionalParams = additionalParams
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        parameters["email"] = email
        
        additionalParams?.forEach { (key, value) in
            parameters[key] = value
        }

        return parameters
    }
}

public struct ProfileCreateRequest1: APIRequest {
    let additionalParams: [String : Any]?

    public init(additionalParams: [String: Any]? = nil) {
        self.additionalParams = additionalParams
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        additionalParams?.forEach { (key, value) in
            parameters[key] = value
        }

        return parameters
    }
}

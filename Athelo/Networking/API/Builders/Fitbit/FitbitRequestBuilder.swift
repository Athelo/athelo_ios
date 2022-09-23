//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import Foundation

enum FitbitRequestBuilder: APIBuilderProtocol {
    case deleteProfile(FitbitDeleteProfileRequest)
    case initialize
    case profileList
    
    var headers: [String : String]? {
        switch self {
        case .deleteProfile, .initialize, .profileList:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .deleteProfile:
            return .delete
        case .initialize:
            return .post
        case .profileList:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .deleteProfile(let request as APIRequest):
            return request.parameters
        case .initialize, .profileList:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .deleteProfile(let request):
            return "/health/integrations/fitbit/profile/\(request.id)/"
        case .initialize:
            return "/health/integrations/fitbit/authorize/initialize/"
        case .profileList:
            return "/health/integrations/fitbit/profile/"
        }
    }
}

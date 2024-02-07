//
//  AppointmentRequestBuilder.swift
//  Athelo
//
//  Created by Devsto on 05/02/24.
//

import Foundation

enum AppointmentRequestBuilder: APIBuilderProtocol{
    case providers
    case providerAvability(request: ProviderAvabilityRequest)
    
    var headers: [String : String]? {
        switch self {
        case .providers, .providerAvability:
            return nil
        
        }
    }
    
    var method: APIMethod {
        switch self {
        case .providers, .providerAvability:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .providerAvability(let request as APIRequest):
            return request.parameters
        case .providers:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .providers:
            return "/providers"
        case .providerAvability(request: let request):
            return "/providers/\(request.id)/availability"
        }
    }
    
    
}

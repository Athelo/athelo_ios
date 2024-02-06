//
//  AppointmentRequestBuilder.swift
//  Athelo
//
//  Created by Devsto on 05/02/24.
//

import Foundation

enum AppointmentRequestBuilder: APIBuilderProtocol{
    case providers

    
    var headers: [String : String]? {
        switch self {
        case .providers:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .providers:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .providers:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .providers:
            return "/providers"
        }
    }
    
    
}

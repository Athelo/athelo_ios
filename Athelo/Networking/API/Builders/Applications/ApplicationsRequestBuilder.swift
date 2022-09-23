//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 21/07/2022.
//

import Foundation

enum ApplicationsRequestBuilder: APIBuilderProtocol {
    case applications
    
    var headers: [String : String]? {
        switch self {
        case .applications:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .applications:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case.applications:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .applications:
            return "/applications/applications/"
        }
    }
}

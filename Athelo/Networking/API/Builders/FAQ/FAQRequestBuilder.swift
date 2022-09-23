//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Foundation

enum FAQRequestBuilder: APIBuilderProtocol {
    case list
    
    var headers: [String : String]? {
        switch self {
        case .list:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .list:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .list:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .list:
            return "/applications/frequently_asked_question/"
        }
    }
}

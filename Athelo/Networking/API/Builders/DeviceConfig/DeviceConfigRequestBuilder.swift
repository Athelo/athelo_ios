//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

enum DeviceConfigRequestBuilder: APIBuilderProtocol {
    case deviceConfig
    
    var headers: [String : String]? {
        switch self {
        case .deviceConfig:
            return nil
        }
    }
    
    var method: APIMethod {
        switch self {
        case .deviceConfig:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .deviceConfig:
            return nil
        }
    }
    
    var path: String {
        switch self {
        case .deviceConfig:
            return "/device_config/get_my_device_configs/"
        }
    }
}

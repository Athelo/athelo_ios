//
//  CommonError.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import Foundation

enum CommonError: LocalizedError {
    case decodingError
    case invalidUserRole
    case missingContent
    case missingCredentials
    case missingDeviceData
    
    var errorDescription: String? {
        switch self {
        case .decodingError:
            return "error.decoding".localized()
        case .invalidUserRole:
            return "error.invalidrole".localized()
        case .missingContent:
            return "error.content".localized()
        case .missingCredentials:
            return "error.missingcredentials".localized()
        case .missingDeviceData:
            return "error.nodevicedata".localized()
        }
    }
}

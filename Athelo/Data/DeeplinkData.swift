//
//  DeeplinkData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 05/07/2022.
//

import Foundation

enum DeeplinkType {
    case operationFailure
    case operationSuccess
    
    init?(deeplink: URL) {
        guard let scheme = deeplink.scheme,
              scheme == "atheloapp" else {
            return nil
        }
        
        switch deeplink.host {
        case "success":
            self = .operationSuccess
        case "fail", "failure":
            self = .operationFailure
        default:
            return nil
        }
    }
}

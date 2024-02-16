//
//  ProfileTreatmentStatus.swift
//  Athelo
//
//  Created by RD Singh on 2024-02-05.
//

import Foundation

public struct ProfileTreatmentStatus: APIRequest {
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

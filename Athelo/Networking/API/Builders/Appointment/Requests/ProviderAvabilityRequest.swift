//
//  ProviderAvabilityRequest.swift
//  Athelo
//
//  Created by Devsto on 07/02/24.
//

import Foundation
public struct ProviderAvabilityRequest: APIRequest {
    let id: Int
    let date: String
    let timeZone: String
    
    public init(id: Int ,date: String) {
        self.id = id
        self.date = date
        self.timeZone = TimeZone.current.identifier
    }
    
    public var parameters: [String : Any]? {
        return nil
    }
}

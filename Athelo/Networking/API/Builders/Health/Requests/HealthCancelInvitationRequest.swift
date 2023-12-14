//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 31/03/2023.
//

import Foundation

public struct HealthCancelInvitationRequest: APIRequest {
    let invitationID: Int
    
    public init(invitationID: Int) {
        self.invitationID = invitationID
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

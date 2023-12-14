//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Foundation

public struct HealthAcceptCaregiverInvitationRequest: APIRequest {
    let invitationCode: String
    
    public init(invitationCode: String) {
        self.invitationCode = invitationCode
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

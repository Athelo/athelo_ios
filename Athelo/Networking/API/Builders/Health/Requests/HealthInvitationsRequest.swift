//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 30/03/2023.
//

import Foundation

public struct HealthInvitationsRequest: APIRequest {
    public enum Status {
        case consumed
        case processing
        case sent
        case timedOut
        case cancelled
        
        var parameterName: String {
            switch self {
            case .consumed:
                return "consumed"
            case .cancelled:
                return "canceled"
            case .sent:
                return "sent"
            case .timedOut:
                return "timeout"
            case .processing:
                return "processing"
            }
        }
    }
    
    let invitationIDs: [Int]?
    let statuses: [Status]?
    
    public init(invitationIDs: [Int]? = nil, statuses: [Status]? = nil) {
        self.invitationIDs = invitationIDs
        self.statuses = statuses
    }
    
    public var parameters: [String : Any]? {
        nil
    }
}

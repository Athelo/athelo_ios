//
//  JoinAppointmentRequedst.swift
//  Athelo
//
//  Created by Devsto on 14/02/24.
//

import Foundation


public struct JoinAppointmentRequest: APIRequest {
    let id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var parameters: [String : Any]? {
        return nil
    }
}

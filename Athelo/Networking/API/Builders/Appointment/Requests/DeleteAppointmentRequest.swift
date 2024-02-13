//
//  DeleteAppointmentRequest.swift
//  Athelo
//
//  Created by Devsto on 08/02/24.
//

import Foundation


public struct DeleteAppointmentRequest: APIRequest {
    let id: Int
    
    public init(id: Int) {
        self.id = id
    }
    
    public var parameters: [String : Any]? {
        return nil
    }
}

//
//  BookAppoointmentRequest.swift
//  Athelo
//
//  Created by Devsto on 08/02/24.
//

import Foundation

public struct BookAppoointmentRequest: APIRequest {
    let id: Int
    let statrtTime: String
    let endTime: String
    let timeZon: String
    
    
    public init(id: Int, starTime: String, endTime: String) {
        self.id = id
        self.statrtTime = starTime
        self.endTime = endTime
        timeZon = TimeZone.current.identifier
        
    }
    
    public var parameters: [String : Any]? {
        return [
            "provider_id": id,
            "start_time": statrtTime,
            "end_time": endTime,
            "timezone": timeZon
        ]
    }
}

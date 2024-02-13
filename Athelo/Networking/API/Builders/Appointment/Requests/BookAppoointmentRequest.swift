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
    var endTime: String {
        get{
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            var startDate = dateformatter.date(from: statrtTime)!
            
            var calendar = Calendar.current

            // Add 30 minutes to the initial date
            if let newDate = calendar.date(byAdding: .minute, value: 30, to: startDate) {
                return dateformatter.string(from: newDate)
            }
            
            return statrtTime
            
        }
    }
    let timeZone: String
    
    
    public init(id: Int, starTime: String) {
        self.id = id
        self.statrtTime = starTime
        timeZone = TimeZone.current.identifier
        
    }
    
    public var parameters: [String : Any]? {
        return [
            "provider_id": id,
            "start_time": statrtTime,
            "end_time": endTime,
            "timezone": timeZone  //"Asia/Calcutta"
        ]
    }
}

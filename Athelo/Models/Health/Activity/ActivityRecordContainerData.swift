//
//  ActivityRecordContainerData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 16/08/2022.
//

import Foundation

struct ActivityRecordContainerData: Decodable {    
    let items: [Date: ActivityRecordData]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let containerValue = try container.decode([String: ActivityRecordData].self)
        
        var values: [Date: ActivityRecordData] = [:]
        
        for (key, record) in containerValue {
            guard let date = key.toDate("yyyy-MM-dd'T'HH:mm:ss")?.date else {
                throw CommonError.decodingError
            }
            
            values[date] = record
        }
        
        self.items = values
    }
}

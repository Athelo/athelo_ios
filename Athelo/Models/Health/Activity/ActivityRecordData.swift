//
//  ActivityRecordData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 16/08/2022.
//

import Foundation

struct ActivityRecordData: Decodable {
    let calories: Int
    let durationSeconds: Int
    let steps: Int
    
    private enum CodingKeys: String, CodingKey {
        case calories, steps
        
        case durationSeconds = "duration_seconds"
    }
}

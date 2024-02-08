//
//  AppoitmentResponseData.swift
//  Athelo
//
//  Created by Devsto on 08/02/24.
//

import Foundation

struct AppoitmentResponseData: Decodable {
    
    let results: [AppointmetntData]
//    let count: Int
//    let next: Int?
//    let previous: Int?
//    
//    enum CodingKeys: CodingKey {
//        case results
//        case count
//        case next
//        case previous
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.results = try container.decode([AppointmetntData].self, forKey: .results)
//        self.count = try container.decode(Int.self, forKey: .count)
//        self.next = try container.decodeIfPresent(Int.self, forKey: .next)
//        self.previous = try container.decodeIfPresent(Int.self, forKey: .previous)
//    }
}

//
//  FitbitProfileData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/08/2022.
//

import Foundation

struct FitbitProfileData: Decodable, Identifiable {
    let id: Int
    
    let externalID: String
    let scopes: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id, scopes
        
        case externalID = "external_id"
    }
}

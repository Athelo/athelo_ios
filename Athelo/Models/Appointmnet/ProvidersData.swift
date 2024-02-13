//
//  AppintmentData.swift
//  Athelo
//
//  Created by Devsto on 05/02/24.
//

import Foundation

struct ProviderResponselData: Decodable {
    var count: Int
    var next: Int?
    var previous: Int?
    var results: [ProvidersData] = []
    
    
    struct ProvidersData: Decodable, Identifiable, Hashable{
        var id: Int
        var name: String?
        var photo: String?
        var providerType: String?
        
     
        
        private enum CodingKeys: String, CodingKey {
            case id, photo
            case name = "display_name"
            case providerType = "provider_type"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decodeValue(forKey: .id)
            
            self.name = try container.decodeValueIfPresent(forKey: .name)
            self.photo = try container.decodeValueIfPresent(forKey: .photo)
            self.providerType = try container.decodeValueIfPresent(forKey: .providerType)
        }
        
    }

}

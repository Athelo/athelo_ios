//
//  AppointmetntData.swift
//  Athelo
//
//  Created by Devsto on 08/02/24.
//

import Foundation

public struct AppointmetntData: Decodable {
 
    let id        : Int
    let startTime : String
    let endTime   : String
    let patient   : PersonData
    let provider  : PersonData
    let vonageSession: String?
    let zoomHostUrl  : String?
    let zoomJoinUrl  : String?
    
    
    private enum CodingKeys: String, CodingKey {
        case id, patient, provider
        case startTime = "start_time"
        case endTime    = "end_time"
        case vonageSession = "vonage_session"
        case zoomHostUrl = "zoom_host_url"
        case zoomJoinUrl = "zoom_join_url"
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.patient = try container.decode(PersonData.self, forKey: .patient)
        self.provider = try container.decode(PersonData.self, forKey: .provider)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.endTime = try container.decode(String.self, forKey: .endTime)
        self.vonageSession = try container.decode(String?.self, forKey: .vonageSession)
        self.zoomHostUrl = try container.decode(String?.self, forKey: .zoomHostUrl)
        self.zoomJoinUrl = try container.decode(String?.self, forKey: .zoomJoinUrl)
    }
    
    struct PersonData: Decodable {
        let name: String
        let photo: String
        
        private enum CodingKeys: String, CodingKey {
            case photo
            case name = "display_name"
        }
        
        init(name: String, photo: String) {
            self.name = name
            self.photo = photo
        }
    }
    
}

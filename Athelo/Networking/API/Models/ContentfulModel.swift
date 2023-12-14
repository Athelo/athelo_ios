//
//  ContentfulModel.swift
//  Athelo
//
//  Created by FS-EMP-2 on 2023-10-27.
//

import Foundation
import Contentful

//
class ContentfulModel: EntryDecodable {
    static var contentTypeId: Contentful.ContentTypeId = ""
    
    var id: String
    
    var updatedAt: Date?
    
    var createdAt: Date?
    
    var localeCode: String?
    
    let title: String
    let description: String
    let imageURL: String
    
    public required init(from decoder: Decoder) throws {
//        let sys = try decoder.sys()
        title              = "sys.title"
        description      = "sys.description"
        imageURL       = "sys.imageURL"
        id = ""
        
//        let fields      = try decoder.contentfulFieldsContainer(keyedBy: ContentfulModel.FieldKeys.self)
//        self.title   = try fields.decodeIfPresent(String.self, forKey: .title)
//        self.description       = try fields.decodeIfPresent(String.self, forKey: .description)
//        self.imageURL      = try fields.decodeIfPresent(String.self, forKey: .imageURL)
    }
    
    enum FieldKeys: String, CodingKey {
        case title
        case description
        case imageURL
    }
}

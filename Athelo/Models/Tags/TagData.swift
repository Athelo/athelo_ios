//
//  TagData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

struct TagData: Decodable, Identifiable {
    let id: Int

    let category: TagCategoryData
    let name: String
    let parentID: Int?
    let parentTags: [TagData]?

    private enum CodingKeys: String, CodingKey {
        case category, id, name
        case parentID = "parent_id"
        case parentTags = "parent_tags"
    }
}

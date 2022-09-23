//
//  TagCategoryData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

struct TagCategoryData: Decodable, Identifiable {
    let id: Int
    let name: String
    let identifier: String
    let autoInsertOnly: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, identifier, name
        case autoInsertOnly = "auto_insert_only"
    }
}

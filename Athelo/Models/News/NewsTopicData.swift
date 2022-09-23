//
//  NewsTopicData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/07/2022.
//

import Foundation

struct NewsTopicData: Decodable, Identifiable {
    let id: Int
    let name: String
}

extension NewsTopicData: Filterable {
    var filterOptionID: Int {
        id
    }
    
    var filterOptionName: String {
        name
    }
}

//
//  FeedbackTopicData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/06/2022.
//

import Foundation

struct FeedbackTopicData: Decodable, Identifiable {
    let id: Int
    
    let category: Int
    let name: String
}

extension FeedbackTopicData: ListInputCellItemData {
    var listInputItemID: Int {
        id
    }
    
    var listInputItemName: String {
        name
    }
}

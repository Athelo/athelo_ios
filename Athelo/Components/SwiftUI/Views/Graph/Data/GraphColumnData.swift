//
//  GraphColumnData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

struct GraphColumnData: Equatable, Hashable, Identifiable {
    let id: Int
    let items: [GraphColumnItemData]
    let label: String
    let secondaryLabel: String?
    
    init(id: Int, items: [GraphColumnItemData], label: String, secondaryLabel: String? = nil) {
        self.id = id
        self.items = items
        self.label = label
        self.secondaryLabel = secondaryLabel
    }
}

//
//  SmallColumnGraphModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

final class SmallColumnGraphModel: ObservableObject {
    @Published private(set) var items: [GraphColumnItemData]
    
    init(items: [GraphColumnItemData]) {
        self.items = items
    }
    
    func updateItems(_ items: [GraphColumnItemData]) {
        self.items = items
    }
}

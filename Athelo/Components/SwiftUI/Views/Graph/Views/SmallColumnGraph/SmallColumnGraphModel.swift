//
//  SmallColumnGraphModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import Foundation

// NOTE: This is a workaround (rawValues and maxValue properties) for model update events (since graph is being drawn based on actual values). Published is being Published.
final class SmallColumnGraphModel: ObservableObject {
    @Published private(set) var items: [GraphColumnItemData]
    
    private(set) var maxValue: CGFloat = 0.0
    private(set) var rawItems: [GraphColumnItemData]
    
    init(items: [GraphColumnItemData]) {
        self.rawItems = items
        self.maxValue = items.map({ $0.value }).max() ?? 0.0
        
        self.items = items
    }
    
    func updateItems(_ items: [GraphColumnItemData]) {
        self.rawItems = items
        self.maxValue = items.map({ $0.value }).max() ?? 0.0
        
        self.items = items
    }
}

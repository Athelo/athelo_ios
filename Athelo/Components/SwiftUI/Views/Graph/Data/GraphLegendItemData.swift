//
//  GraphLegendItemData.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import Foundation

struct GraphLegendItemData: Hashable, Identifiable {
    let id: Int
    let name: String
}

final class GraphLegendItemsModel: ObservableObject {
    @Published var legendItems: [GraphLegendItemData]
    @Published var spacingGap: Double
    
    init(legendItems: [GraphLegendItemData], spacingGap: Double = 0.25) {
        self.legendItems = legendItems
        self.spacingGap = max(0.0, min(1.0, spacingGap))
    }
}

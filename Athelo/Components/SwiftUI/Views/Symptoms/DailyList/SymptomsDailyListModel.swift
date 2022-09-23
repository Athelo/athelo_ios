//
//  SymptomsDailyListModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation

final class SymptomsDailyListModel: ObservableObject {
    @Published private(set) var items: [ListItem]
    @Published private(set) var shouldLoadMore: Bool
    
    init(items: [SymptomDaySummaryData], shouldLoadMore: Bool = false) {
        self.items = SymptomsDailyListModel.rebuildSymptomSummaryData(items)
        self.shouldLoadMore = shouldLoadMore
    }
    
    func appendItems(_ items: [SymptomDaySummaryData], shouldLoadMore: Bool = false) {
        self.items.append(contentsOf: SymptomsDailyListModel.rebuildSymptomSummaryData(items, lastListItem: self.items.last?.symptomData))
        self.shouldLoadMore = shouldLoadMore
    }
    
    func updateItems(_ items: [SymptomDaySummaryData], shouldLoadMore: Bool = false) {
        self.items = SymptomsDailyListModel.rebuildSymptomSummaryData(items)
        self.shouldLoadMore = shouldLoadMore
    }
}

extension SymptomsDailyListModel {
    struct ListItem: Equatable, Identifiable {
        let symptomData: SymptomDaySummaryData
        let displaysYearSeparator: Bool
        
        var id: Date {
            symptomData.date
        }
    }
    
    private static func rebuildSymptomSummaryData(_ data: [SymptomDaySummaryData], lastListItem: SymptomDaySummaryData? = nil) -> [ListItem] {
        var items: [ListItem] = []
        
        for symptomData in data.enumerated() {
            var displaysYearSeparator = false
            if symptomData.element == data.first {
                displaysYearSeparator = lastListItem != nil ? (symptomData.element.date.year != lastListItem?.date.year) : true
            } else if let previousItem = data[safe: symptomData.offset - 1] {
                displaysYearSeparator = symptomData.element.date.year != previousItem.date.year
            }
            
            items.append(.init(symptomData: symptomData.element, displaysYearSeparator: displaysYearSeparator))
        }
        
        return items
    }
}

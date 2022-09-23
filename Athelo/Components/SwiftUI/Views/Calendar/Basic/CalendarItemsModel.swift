//
//  CalendarItemsModel.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 23/06/2022.
//

import Foundation

final class CalendarItemsModel: ObservableObject {
    struct CalendarItem: Identifiable {
        let text: String
        
        var id: String {
            text
        }
    }
    
    @Published private(set) var displayedItems: [CalendarItem] = Calendar.current.shortMonthSymbols.map({ CalendarItem(text: $0) })
    @Published private(set) var displaysYears: Bool = false
    
    private var currentYearMatrix: [Int]?
    
    func canSelectNextMatrix() -> Bool {
        guard displaysYears, let lastYear = currentYearMatrix?.last else {
            return false
        }
        
        return lastYear + 1 <= Date().year
    }
    
    func canSelectPreviousMatrix() -> Bool {
        guard displaysYears, let firstYear = currentYearMatrix?.first else {
            return false
        }
        
        return firstYear - 1 >= Date().year - 150
    }
    
    func selectNextYearMatrix() {
        guard canSelectNextMatrix(),
              let currentMatrix = currentYearMatrix else {
            return
        }
        
        let targetMatrix = currentMatrix.map({ $0 + 16 })
        
        currentYearMatrix = targetMatrix
        displayedItems = targetMatrix.map({ CalendarItem(text: "\($0)") })
    }
    
    func selectPreviousYearMatrix() {
        guard canSelectPreviousMatrix(),
              let currentMatrix = currentYearMatrix else {
            return
        }
        
        let targetMatrix = currentMatrix.map({ $0 - 16 })
        
        currentYearMatrix = targetMatrix
        displayedItems = targetMatrix.map({ CalendarItem(text: "\($0)") })
    }
    
    func switchDisplayedItems(relativeTo date: Date) {
        displaysYears.toggle()
        
        if displaysYears {
            var referenceYear = date.year
            
            var targetMatrix: [Int] = []
            while targetMatrix.count < 16 {
                targetMatrix.append(referenceYear)
                referenceYear += 1
            }
            
            currentYearMatrix = targetMatrix
            displayedItems = targetMatrix.map({ CalendarItem(text: "\($0)") })
        } else {
            currentYearMatrix = nil
            displayedItems = Calendar.current.shortMonthSymbols.map({ CalendarItem(text: $0) })
        }
    }
}

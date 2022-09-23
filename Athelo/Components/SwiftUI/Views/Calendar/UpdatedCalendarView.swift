//
//  UpdatedCalendarView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import SwiftDate
import SwiftUI

struct CalendarItem: Identifiable {
    let text: String
    
    var id: String {
        text
    }
}

final class UpdatedCalendarModel: ObservableObject {
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
        
        return firstYear - 1 >= 16
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

struct CalendarView: View {
    @ObservedObject private var itemsModel: UpdatedCalendarModel
    @State private(set) var date: Date
    
    weak private(set) var delegate: CalendarViewDelegate?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(date: Date, delegate: CalendarViewDelegate?) {
        self.delegate = delegate
        self._date = State(initialValue: date)
        
        self._itemsModel = ObservedObject(initialValue: UpdatedCalendarModel())
    }
    
    var body: some View {
        VStack(spacing: 24.0) {
            HStack(alignment: .center, spacing: 24.0) {
                HStack(alignment: .center, spacing: 8.0) {
                    StyledText(date.toFormat("MMMM YYYY"),
                               textStyle: .paragraph,
                               colorStyle: .black,
                               extending: false,
                               alignment: .leading)
                    
                    Button {
                        withAnimation {
                            itemsModel.switchDisplayedItems(relativeTo: date)
                        }
                    } label: {
                        Image("arrowDown")
                            .rotationEffect(.degrees(itemsModel.displaysYears ? 180.0 : 0.0))
                    }
                }

                Spacer()
                
                if itemsModel.displaysYears {
                    Group {
                        Button {
                            itemsModel.selectPreviousYearMatrix()
                        } label: {
                            Image("arrowLeft")
                                .opacity(itemsModel.canSelectPreviousMatrix() ? 1.0 : 0.5)
                        }
                        
                        Button {
                            itemsModel.selectNextYearMatrix()
                        } label: {
                            Image("arrowRight")
                                .opacity(itemsModel.canSelectNextMatrix() ? 1.0 : 0.5)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding([.top], 8.0)
            .padding([.leading, .trailing], 8.0)
            
            LazyVGrid(columns: columns) {
                ForEach(itemsModel.displayedItems) { item in
                    StyledText(item.text,
                               textStyle: .textField,
                               colorStyle: hasSelected(symbol: item.text) ? .white : .gray)
                    .opacity(opacity(for: item.text))
                    .frame(width: 72.0, height: 36.0, alignment: .center)
                    .background(Rectangle().fill(hasSelected(symbol: item.text) ? Color(UIColor.withStyle(.purple623E61).cgColor) : Color.clear), alignment: .center)
                    .clipShape(Capsule())
                    .onTapGesture {
                        handleSelection(of: item.text)
                    }
                    .animation(.default, value: date)
                }
            }
        }
        .padding(16.0)
        .background(Rectangle().fill(Color.white), alignment: .center)
        .cornerRadius(30.0)
        .animation(.linear.speed(1.5), value: itemsModel.displaysYears)
        .onChange(of: date, perform: { newValue in
            delegate?.calendarViewUpdatedDate(newValue)
        })
    }
    
    private func handleSelection(of symbol: String) {
        let today = Date()
        
        if itemsModel.displaysYears {
            guard let year = Int(symbol),
                  year <= today.year else {
                return
            }
            
            var targetMonth = date.month
            if year == today.year, targetMonth > today.month {
                targetMonth = today.month
            }
            
            let targetDate = Date(year: year, month: targetMonth, day: date.day, hour: date.hour, minute: date.minute)

            self.date = targetDate
            itemsModel.switchDisplayedItems(relativeTo: date)
        } else {
            guard let monthIndex = itemsModel.displayedItems.map({ $0.text }).firstIndex(where: { symbol == $0 }) else {
                return
            }
            
            var dateComps = date.dateComponents
            dateComps.month = monthIndex + 1
            dateComps.day = 15
            
            guard let targetDate = Date(components: dateComps, region: .current) else {
                return
            }
            
            if targetDate.year == today.year {
                guard targetDate.month <= today.month else {
                    return
                }
            }
            
            self.date = targetDate
        }
    }
    
    private func hasSelected(symbol: String) -> Bool {
        if itemsModel.displaysYears {
            guard let year = Int(symbol) else {
                return false
            }
            
            return year == date.year
        } else {
            let month = symbol.toDate("MMM", region: .current)?.dateComponents.month
            return date.month == month
        }
    }
    
    private func opacity(for symbol: String) -> CGFloat {
        let today = Date()
        
        if itemsModel.displaysYears {
            guard let year = Int(symbol) else {
                return 0.5
            }
            
            return year <= today.year ? 1.0 : 0.5
        } else {
            guard let monthIndex = itemsModel.displayedItems.map({ $0.text }).firstIndex(where: { symbol == $0 }) else {
                return 0.5
            }
            
            if date.year < today.year {
                return 1.0
            }
            
            return monthIndex + 1 <= today.month ? 1.0 : 0.5
        }
    }
}

struct UpdatedCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
                .background(Color.blue, alignment: .center)
                .ignoresSafeArea()
            
            VStack(spacing: 24.0) {
                UpdatedCalendarView(date: Date(), delegate: nil)
                    .padding()
            }
        }
    }
}

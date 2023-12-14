//
//  HorizontalWeekContainerView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import SwiftDate
import SwiftUI

struct HorizontalWeekContainerView: View {
    struct DateItem: Identifiable {
        let date: Date
        
        var id: Date {
            date
        }
    }
    
    @ObservedObject private(set) var selectedDateModel: SelectedDateModel
    let items: [DateItem]
    
    init(model: SelectedDateModel, lastDisplayedDate: Date) {
        self.items = (-6...0).map({ DateItem(date: lastDisplayedDate.dateByAdding($0, .day).date) })
        self.selectedDateModel = model
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func isSelected(_ date: Date) -> Bool {
        return Calendar.current.compare(date, to: selectedDateModel.date, toGranularity: .day) == .orderedSame
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(items) { item in
                VStack(alignment: .center, spacing: 2.0) {
                    StyledText(item.date.in(region: .local).toFormat("dd"),
                               textStyle: .button,
                               colorStyle: isSelected(item.date) ? .purple623E61 : .black)
                        
                    StyledText(item.date.in(region: .local).toFormat("EEEEEE"),
                               textStyle: .body,
                               colorStyle: isSelected(item.date) ? .purple623E61 : .lightGray)
                }
                .scaleEffect(isSelected(item.date) ? 1.1 : 1.0)
                .padding(8.0)
                .frame(
                    minWidth: isSelected(item.date) ? 50.0 : nil,
                    minHeight: isSelected(item.date) ? 63.0 : nil
                )
                .background(
                    Rectangle()
                        .fill(isSelected(item.date) ? Color(UIColor.withStyle(.purple988098).cgColor).opacity(0.17) : .clear))
                .cornerRadius(16.0)
                .animation(.default, value: selectedDateModel.date)
                .onTapGesture {
                    selectedDateModel.date = item.date
                }
            }
        }
        .frame(minHeight: 63.0)
        .padding([.leading, .trailing], 8.0)
        .clipped()
    }
}

struct HorizontalWeekContainerView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalWeekContainerView(model: SelectedDateModel(date: Date()), lastDisplayedDate: Date())
    }
}

//
//  CalendarWeekView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/07/2022.
//

import SwiftDate
import SwiftUI

struct CalendarWeekView: View {
    @ObservedObject private(set) var model: SelectedDateModel
    let lastDay: Date
    
    var body: some View {
        VStack(spacing: 16.0) {
            HStack(alignment: .center, spacing: 24.0) {
                VStack(alignment: .leading, spacing: 4.0) {
                    StyledText(model.date.toFormat("MMMM dd, yyyy"),
                               textStyle: .body,
                               colorStyle: .gray,
                               alignment: .leading)
                    
                    StyledText(model.date.toFormat("EEEE"),
                               textStyle: .headline20,
                               colorStyle: .black,
                               alignment: .leading)
                }
                .animation(nil, value: model.date)
                
                Spacer()
            }
            .padding([.leading, .trailing], 16.0)
            
            HorizontalWeekContainerView(model: model, lastDisplayedDate: lastDay)
        }
    }
}

struct CalendarWeekView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWeekView(model: SelectedDateModel(date: Date()), lastDay: Date())
    }
}

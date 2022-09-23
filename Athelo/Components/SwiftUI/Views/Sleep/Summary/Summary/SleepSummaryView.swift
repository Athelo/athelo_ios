//
//  SleepSummaryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

struct SleepSummaryView: View {
    @ObservedObject var model: SleepSummaryModel
    
    private let headerActionTapHandler: () -> Void
    private let summaryActionTapHandler: () -> Void
    
    init(model: SleepSummaryModel, headerActionTapHandler: @escaping () -> Void, summaryActionTapHandler: @escaping () -> Void) {
        self.model = model
        
        self.headerActionTapHandler = headerActionTapHandler
        self.summaryActionTapHandler = summaryActionTapHandler
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24.0) {
                if model.displaysHeader {
                    SleepSummaryHeaderView(linkTapAction: headerActionTapHandler)
                        .environmentObject(model.headerModel)
                        .zIndex(3)
                }
                
                SleepSummaryAverageView()
                    .environmentObject(model)
                    .zIndex(1)
                
                SleepSummaryStatsView(linkTapAction: summaryActionTapHandler)
                    .environmentObject(model)
                    .zIndex(2)
            }
            .padding(.top, 24.0)
            .padding([.leading, .trailing, .bottom], 16.0)
        }
        .background(Rectangle().fill(.clear))
    }
}

struct SleepSummaryView_Previews: PreviewProvider {
    private static let model = SleepSummaryModel()
    
    static var previews: some View {
        VStack {
            SleepSummaryView(model: model) {
                /* ... */
            } summaryActionTapHandler: {
                /* ... */
            }
            
            Button {
                let data = SleepTimeData(
                    awakeTime: .random(in: 0...10800),
                    deepSleepTime: .random(in: 0...10800),
                    lightSleepTime: .random(in: 0...10800),
                    remSleepTime: .random(in: 0...10800)
                )
                
                model.updateSummaryData(.init(sleepTime: data), weeklyAvgSleepTime: 0.0)
            } label: {
                Text("Set random minutes of sleep")
                    .underline()
            }
        }
    }
}

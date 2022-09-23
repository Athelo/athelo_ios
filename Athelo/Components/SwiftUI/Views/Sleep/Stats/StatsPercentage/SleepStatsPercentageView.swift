//
//  StatsStagePercentage.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 29/07/2022.
//

import SwiftUI

struct SleepStatsPercentageView: View {
    @EnvironmentObject var model: SleepStatsContainerModel
    
    var body: some View {
        HStack {
            SleepStatsSinglePercentageView(percentage: model.percentage(for: .deep), phase: .deep)
            
            Divider()
                .overlay(Color(UIColor.withStyle(.lightGray).cgColor))
            
            SleepStatsSinglePercentageView(percentage: model.percentage(for: .rem), phase: .rem)
            
            Divider()
                .overlay(Color(UIColor.withStyle(.lightGray).cgColor))
            
            SleepStatsSinglePercentageView(percentage: model.percentage(for: .light), phase: .light)
        }
    }
}

struct SleepStatsPercentageView_Previews: PreviewProvider {
    private static let model = SleepStatsContainerModel()
    
    static var previews: some View {
        SleepStatsPercentageView()
            .environmentObject(model)
    }
}

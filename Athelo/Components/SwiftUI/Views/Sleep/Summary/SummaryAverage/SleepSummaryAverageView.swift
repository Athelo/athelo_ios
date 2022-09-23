//
//  SleepSummaryAverageView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

struct SleepSummaryAverageView: View {
    @EnvironmentObject var model: SleepSummaryModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            StyledText(model.summaryData != nil
                        ? "You almost reach a perfect week of sleep"
                        : "No figures for this week",
                       textStyle: .paragraph,
                       colorStyle: .gray,
                       alignment: .leading)
            
            CircularProgressView()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(height: 100.0, alignment: .center)
                .environmentObject(model.progressModel)
        }
        .padding(16.0)
        .background(
            ZStack {
                Rectangle().fill(Color(UIColor.withStyle(.background).cgColor))
                
                Image("wavesBackground")
                    .opacity(0.2)
                    .offset(x: 0.0, y: 20.0)
            },
            alignment: .center)
        .cornerRadius(30.0)
        .styledShadow()
    }
}

struct SleepSummaryAverageView_Previews: PreviewProvider {
    private static let model = SleepSummaryModel()
    
    static var previews: some View {
        SleepSummaryAverageView()
            .padding()
            .environmentObject(model)
    }
}

//
//  SleepStatsLegendView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct SleepStatsLegendView: View {
    private let grid: [GridItem] = {
        [
            .init(.flexible()),
            .init(.flexible()),
            .init(.flexible()),
        ]
    }()
    
    var body: some View {
        LazyVGrid(columns: grid) {
            ForEach(SleepPhase.legendSorted(), id: \.self) { phase in
                phase.legendView()
            }
            
            SleepStatsLegendItemView(text: "sleep.phase.total".localized(),
                                     fillColor: .withStyle(.white),
                                     borderGradientColors: [
                                        .withStyle(.olivaceous),
                                        .withStyle(.lightOlivaceous)
                                     ])
        }
    }
}

struct SleepStatsLegendView_Previews: PreviewProvider {
    static var previews: some View {
        SleepStatsLegendView()
            .padding()
    }
}

private extension SleepPhase {
    static func legendSorted() -> [Self] {
        [.rem, .deep, .light]
    }
    
    @ViewBuilder
    func legendView() -> some View {
        SleepStatsLegendItemView(text: name, fillColor: color)
    }
}

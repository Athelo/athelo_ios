//
//  SleepStatsLegendItemView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct SleepStatsLegendItemView: View {
    let text: String
    let fillColor: UIColor
    let borderGradientColors: [UIColor]
    
    init(text: String, fillColor: UIColor, borderGradientColors: [UIColor] = [.clear]) {
        self.text = text
        self.fillColor = fillColor
        self.borderGradientColors = borderGradientColors
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Rectangle()
                .fill(Color(fillColor.cgColor))
                .cornerRadius(5.0)
                .frame(width: 24.0, height: 16.0, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.linearGradient(colors: borderGradientColors.map({ Color($0.cgColor) }),
                                                startPoint: .top,
                                                endPoint: .bottom), lineWidth: 2.0)
                )

            
            StyledText(text,
                       textStyle: .body,
                       colorStyle: .gray,
                       alignment: .leading)
        }
    }
}

struct SleepStatsLegendItemView_Previews: PreviewProvider {
    static var previews: some View {
        SleepStatsLegendItemView(text: "REM Sleep", fillColor: SleepPhase.rem.color)
            .padding()
    }
}

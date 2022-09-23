//
//  SleepStatsSinglePercentageView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 29/07/2022.
//

import SwiftUI

struct SleepStatsSinglePercentageView: View {
    let percentage: Int
    let phase: SleepPhase
    
    var body: some View {
        VStack(alignment: .center, spacing: 4.0) {
            StyledText("\(percentage)%",
                       textStyle: .boldHeadline20,
                       colorStyle: .lightOlivaceous)
            
            StyledText(phase.name,
                       textStyle: .body,
                       colorStyle: .gray)
        }
    }
}

struct SleepStatsSinglePercentageView_Previews: PreviewProvider {
    static var previews: some View {
        SleepStatsSinglePercentageView(percentage: 58, phase: .deep)
    }
}

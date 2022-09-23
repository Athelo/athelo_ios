//
//  SleepStatsDailyView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct SleepStatsDailyView: View {
    @EnvironmentObject var model: SleepStatsContainerModel
    
    var body: some View {
        HStack {
            VStack(spacing: 16.0) {
                SleepStatsSingleStatView(header: model.deepSleepTime.toSleepTimeString(), text: SleepPhase.deep.name)
                
                SleepStatsSingleStatView(header: model.lightSleepTime.toSleepTimeString(), text: SleepPhase.light.name)
            }
            
            Spacer(minLength: 24.0)
            
            VStack(spacing: 16.0) {
                SleepStatsSingleStatView(header: model.remSleepTime.toSleepTimeString(), text: SleepPhase.rem.name)
                
                SleepStatsSingleStatView(header: model.awakeTime.toSleepTimeString(), text: SleepPhase.wake.name)
            }
        }
        .padding(.horizontal, 16.0)
    }
}

struct SleepStatsDailyView_Previews: PreviewProvider {
    private static let model = SleepStatsContainerModel()
    
    static var previews: some View {
        SleepStatsDailyView()
            .environmentObject(model)
    }
}

private extension SleepStatsContainerModel {
    var awakeTime: TimeInterval {
        dailySummaryData?.awakeTime ?? 0.0
    }
    
    var deepSleepTime: TimeInterval {
        dailySummaryData?.deepSleepTime ?? 0.0
    }
    
    var lightSleepTime: TimeInterval {
        dailySummaryData?.lightSleepTime ?? 0.0
    }
    
    var remSleepTime: TimeInterval {
        dailySummaryData?.remSleepTime ?? 0.0
    }
}

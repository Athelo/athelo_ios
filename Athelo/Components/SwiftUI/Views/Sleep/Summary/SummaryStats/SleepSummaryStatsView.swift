//
//  SleepSummaryStatsView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

struct SleepSummaryStatsView: View {
    @EnvironmentObject var model: SleepSummaryModel
    
    private let linkTapAction: () -> Void
    
    init(linkTapAction: @escaping () -> Void) {
        self.linkTapAction = linkTapAction
    }
    
    var body: some View {
        VStack(spacing: 24.0) {
            StyledText("Sleep Information",
                       textStyle: .headline20,
                       colorStyle: .gray,
                       alignment: .leading)
            
            HStack {
                VStack(spacing: 16.0) {
                    SummarySingleStatView(
                        icon: .init(named: "bookSolid")!,
                        header: model.sleepTime(for: .deep),
                        bodyText: "Deep Sleep",
                        tintColor: .withStyle(.lightOlivaceous)
                    )
                    
                    SummarySingleStatView(
                        icon: .init(named: "bedSolid")!,
                        header: model.sleepTime(for: .light),
                        bodyText: "Light Sleep",
                        tintColor: .withStyle(.lightOlivaceous)
                    )
                }
                
                Spacer(minLength: 32.0)
                
                VStack(spacing: 16.0) {
                    SummarySingleStatView(
                        icon: .init(named: "sleep")!,
                        header: model.sleepTime(for: .rem),
                        bodyText: "REM Sleep",
                        tintColor: .withStyle(.lightOlivaceous)
                    )
                    
                    SummarySingleStatView(
                        icon: .init(named: "sun")!,
                        header: model.sleepTime(for: .wake),
                        bodyText: "Awake",
                        tintColor: .withStyle(.lightOlivaceous)
                    )
                }
            }
            
            Button {
                linkTapAction()
            } label: {
                StyledText("See more",
                           textStyle: .button,
                           colorStyle: .lightOlivaceous,
                           alignment: .leading,
                           underlined: true)
            }
        }
        .padding(16.0)
        .background(Rectangle().fill(Color(UIColor.withStyle(.background).cgColor)), alignment: .center)
        .cornerRadius(30.0)
        .styledShadow()
    }
}

struct SleepSummaryStatsView_Previews: PreviewProvider {
    static let model = SleepSummaryModel()
    
    static var previews: some View {
        SleepSummaryStatsView(linkTapAction: { /* ... */ })
            .padding()
            .environmentObject(model)
    }
}

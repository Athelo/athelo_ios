//
//  ActivitySummaryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import SwiftUI

struct ActivitySummaryView: View {
    @ObservedObject var model: ActivitySummaryModel
    
    private var revealTransition: AnyTransition {
        .slide.combined(with: .opacity)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 24.0) {
                    HStack(alignment: .center) {
                        StyledText(model.overviewHeader,
                                   textStyle: .headline20,
                                   colorStyle: .gray,
                                   alignment: .leading)
                        
                        Spacer()
                        
                        StyledText(model.overviewDescription,
                                   textStyle: .boldHeadline20,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .trailing)
                    }
                    .padding(.horizontal, 16.0)
                    
                    Group {
                        if model.displayedGraph == .column {
                            GraphColumnChartView(
                                model: model.columnChartDataModel,
                                columnBorderGradientColors: [.withStyle(.lightOlivaceous)]
                            )
                        } else if model.displayedGraph == .linear {
                            LinearGraphView(model: model.linearChartDataModel)
                        } else {
                            MultiValueColumnChartView(model: model.multiValueColumnChartModel)
                        }
                    }
                    .frame(height: 305.0, alignment: .center)
                    .padding(.horizontal, 6.0)
                    .transition(revealTransition)
                    
                    if let infoText = model.infoText {
                        HStack(alignment: .top, spacing: 8.0) {
                            Image("infoSolid")
                                .renderingMode(.template)
                                .foregroundColor(Color(UIColor.withStyle(.lightOlivaceous).cgColor))
                            
                            StyledText(infoText,
                                       textStyle: .paragraph,
                                       colorStyle: .gray,
                                       alignment: .leading)
                        }
                        .padding(.horizontal, 16.0)
                        .transition(revealTransition)
                    }
                }
                .padding(.top, 40.0)
                .padding(.bottom, 16.0)
                .animation(.default)
            }
        }
    }
}

struct ActivitySummaryView_Previews: PreviewProvider {
    private static let model = ActivitySummaryModel(activityType: .steps)
    
    static var previews: some View {
        ActivitySummaryView(model: model)
    }
}

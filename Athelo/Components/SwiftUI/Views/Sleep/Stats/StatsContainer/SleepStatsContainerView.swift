//
//  SleepStatsContainerView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftDate
import SwiftUI

// Otherwise, it crashes. In-place (complex?) attributed string generation during SwiftUI view initialization generates runtime AttributeGraph exceptions.
private struct Constants {
    let deepSleepDescription = "sleep.description.phase.deep".localized().toAttributedHTML()
    let lightSleepDescription = "sleep.description.phase.light".localized().toAttributedHTML()
    let remSleepDescription = "sleep.description.phase.rem".localized().toAttributedHTML()
}

struct SleepStatsContainerView: View {
    private let constants = Constants()
    
    @ObservedObject var model: SleepStatsContainerModel
    
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
                        
                        StyledText(model.avgTimeDescription,
                                   textStyle: .boldHeadline20,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .trailing)
                    }
                    .padding(.horizontal, 16.0)
                    
                    VStack {
                        if model.filter == .day {
                            SleepStatsDailyView()
                                .environmentObject(model)
                                .transition(revealTransition)
                        } else {
                            Group {
                                if model.filter == .week {
                                    GraphColumnChartView(model: model.weeklyGraphModel)
                                } else {
                                    GraphColumnChartView(model: model.monthlyGraphModel)
                                }
                            }
                            .frame(height: 305.0, alignment: .center)
                            .padding(.horizontal, 6.0)
                            .transition(revealTransition)
                            
                            VStack(spacing: 4.0) {
                                StyledText(model.avgTimeDescription,
                                           textStyle: .boldHeadline20,
                                           colorStyle: .lightOlivaceous)
                                
                                StyledText("sleep.summary.average.header".localized(),
                                           textStyle: .body,
                                           colorStyle: .gray)
                            }
                            .padding(.horizontal, 16.0)
                            .transition(revealTransition)
                        }
                    }
                    .animation(.default, value: model.filter)
                    
                    if model.filter == .month {
                        SleepStatsPercentageView()
                            .padding(.horizontal, 16.0)
                            .environmentObject(model)
                            .transition(revealTransition)
                            .animation(.default, value: model.filter)
                    }
                    
                    if model.filter == .week {
                        SleepStatsLegendView()
                            .padding(.horizontal, 16.0)
                            .transition(revealTransition)
                            .animation(.default, value: model.filter)
                    }
                    
                    VStack(spacing: 16.0) {
                        HTMLContent(attributedString: constants.deepSleepDescription,
                                    geometry: geometry,
                                    offset: 32.0)
                        
                        HTMLContent(attributedString: constants.remSleepDescription,
                                    geometry: geometry,
                                    offset: 32.0)
                        
                        HTMLContent(attributedString: constants.lightSleepDescription,
                                    geometry: geometry,
                                    offset: 32.0)
                    }
                    .padding(.horizontal, 16.0)
                    
                    if let recommendation = model.recommendation, !recommendation.isEmpty {
                        HStack(alignment: .top, spacing: 8.0) {
                            Image("infoSolid")
                                .renderingMode(.template)
                                .foregroundColor(Color(UIColor.withStyle(.lightOlivaceous).cgColor))
                            
                            StyledText(recommendation,
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
                .animation(.default, value: model.filter)
            }
        }
        .styledBackground(.clear)
    }
}

struct SleepStatsContainerView_Previews: PreviewProvider {
    private static let model: SleepStatsContainerModel = {
        let model = SleepStatsContainerModel()
        
        model.assignFilter(.week)
        model.assignWeeklySummaryData(
            (-6...0).map({
                .init(awakeTime: Bool.random() ? 0 : TimeInterval.random(in: 1800.0...15800.0),
                      deepSleepTime: TimeInterval.random(in: 1800.0...15800.0),
                      lightSleepTime: TimeInterval.random(in: 1800.0...15800.0),
                      remSleepTime: TimeInterval.random(in: 1800.0...15800.0),
                      date: Date().dateByAdding($0, .day).date)
            })
        )
        
        return model
    }()
    
    static var previews: some View {
        SleepStatsContainerView(model: model)
    }
}

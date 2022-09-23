//
//  ActivitySummaryView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import SwiftUI

struct ActivityTilesView: View {
    @ObservedObject var model: ActivityTilesModel
    private(set) var tileTapCallback: ((Tile) -> Void)?
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24.0) {
                if let headerText = model.headerText, !headerText.isEmpty {
                    StyledText(headerText,
                               textStyle: .paragraph,
                               colorStyle: .gray,
                               alignment: .leading)
                    .padding(16.0)
                    .frame(minHeight: 120.0, alignment: .center)
                    .background(
                        ZStack {
                            Rectangle()
                                .fill(Color(UIColor.withStyle(.white).cgColor))
                            
                            Image("wavesBackground")
                                .offset(x: 0.0, y: 24.0)
                                .opacity(0.2)
                        }
                    )
                    .roundedCorners(radius: 30.0)
                    .styledShadow()
                    .transition(.slide.combined(with: .opacity))
                }
                
                LazyVGrid(columns: tilesGrid(), spacing: 24.0) {
                    ForEach(Tile.displayOrdered, id: \.self) { tileType in
                        tile(for: tileType, count: 50)
                    }
                }
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 24.0)
            .animation(.default, value: model.headerText)
        }
    }
    
    private func tilesGrid() -> [GridItem] {
        [
            .init(.flexible(), spacing: 24.0),
            .init(.flexible(), spacing: 24.0)
        ]
    }
    
    @ViewBuilder
    private func tile(for tile: Tile, count: Int? = nil) -> some View {
        switch tile {
        case .activity, .heartRate, .steps:
            let model = graphModel(for: tile)
            
            ActivitySingleColumnTileView(
                image: tile.icon,
                headerText: tile.title,
                unitData: tile.unitData,
                displayedValueConverter: tile.valueConverter
            )
            .environmentObject(model)
            .onTapGesture {
                tileTapCallback?(tile)
            }
        case .hrv:
            ActivitySingleLineTileView(
                image: tile.icon,
                headerText: tile.title,
                unitData: tile.unitData
            )
            .environmentObject(model.hrvGraphModel)
            .onTapGesture {
                tileTapCallback?(tile)
            }
        }
    }
    
    private func graphModel(for tile: Tile) -> SmallColumnGraphModel {
        switch tile {
        case .activity:
            return model.activityGraphModel
        case .heartRate:
            return model.heartRateGraphModel
        case .hrv:
            fatalError("No line graph model for HRV data.")
        case .steps:
            return model.stepsGraphModel
        }
    }
}

extension ActivityTilesView {
    enum Tile: String, Hashable {
        case activity
        case heartRate = "heartrate"
        case hrv
        case steps
        
        static var displayOrdered: [Tile] {
            [.steps, .activity, .heartRate, .hrv]
        }
        
        fileprivate var valueConverter: ((Double) -> Double)? {
            switch self {
            case .activity:
                return { $0 / 60.0 }
            case .heartRate, .hrv, .steps:
                return nil
            }
        }
        
        fileprivate var icon: UIImage {
            switch self {
            case .activity:
                return UIImage(named: "gymSolid")!
            case .heartRate, .hrv:
                return UIImage(named: "heartSolid")!
            case .steps:
                return UIImage(named: "running")!
            }
        }
        
        fileprivate var title: String {
            "activity.summary.tile.\(rawValue).header".localized()
        }
        
        fileprivate var unitData: UnitNameData? {
            switch self {
            case .activity:
                return UnitNameData(
                    plural: "unit.minute.plural".localized(),
                    short: "unit.minute.short".localized(),
                    singular: "unit.minute.singular".localized()
                )
            case .heartRate:
                return UnitNameData(
                    plural: "unit.heartbeat.plural".localized(),
                    short: "unit.heartbeat.short".localized(),
                    singular: "unit.heartbeat.singular".localized()
                )
            case .hrv:
                return UnitNameData(
                    plural: "unit.milisecond.plural".localized(),
                    short: "unit.milisecond.short".localized(),
                    singular: "unit.milisecond.singular".localized()
                )
            case .steps:
                return UnitNameData(
                    plural: "unit.step.plural".localized(),
                    short: "unit.step.short".localized(),
                    singular: "unit.step.singular".localized()
                )
            }
        }
    }
}

struct ActivityTilesView_Previews: PreviewProvider {
    private static let model: ActivityTilesModel = {
        let model = ActivityTilesModel()
        
        model.updateHeaderText("You walked less yesterday than you did the day before.")
        
        model.updateActivityGraphItems(randomGraphItems())
        model.updateHeartRateGraphItems(randomGraphItems())
        model.updateHRVGraphPoints(randomLinePoints())
        model.updateStepsGraphItems(randomGraphItems())
        
        return model
    }()
    
    static var previews: some View {
        VStack {
            ActivityTilesView(model: model, tileTapCallback: { _ in /* ... */ })
            
            HStack {
                Button {
                    model.updateHeaderText(
                        Bool.random() ? nil : (1...Int.random(in: 1...3)).map({ _ in "You walked less yesterday than you did the day before." }).joined(separator: " ")
                    )
                } label: {
                    Text("Update text")
                }
                
                Button {
                    model.updateActivityGraphItems(randomGraphItems())
                    model.updateHeartRateGraphItems(randomGraphItems())
                    model.updateHRVGraphPoints(randomLinePoints())
                    model.updateStepsGraphItems(randomGraphItems())
                } label: {
                    Text("Update graphs")
                }
            }
        }
    }
    
    private static func randomGraphItems() -> [GraphColumnItemData] {
        (0...6).map({
            GraphColumnItemData(id: $0, color: .withStyle(.lightOlivaceous), value: .random(in: 0.0...5.0), label: nil)
        })
    }
    
    private static func randomLinePoints() -> [GraphLinePointData] {
        (0...6).map({
            .init(x: CGFloat($0), y: .random(in: 0.0...1.0))
        })
    }
}

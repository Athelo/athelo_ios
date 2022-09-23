//
//  ActivitySummaryLineTileView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/08/2022.
//

import SwiftUI

struct ActivitySingleLineTileView: View {
    @EnvironmentObject var graphModel: SmallLineGraphModel
    
    let image: UIImage
    let headerText: String
    let unitData: UnitNameData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            HStack(alignment: .center, spacing: 16.0) {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.withStyle(.lightOlivaceous).cgColor))
                
                VStack(alignment: .leading, spacing: 4.0) {
                    StyledText(headerText,
                               textStyle: .subtitle,
                               colorStyle: .lightOlivaceous,
                               alignment: .leading)
                    
                    if let unitData = unitData,
                       let value = graphModel.points.last?.y {
                        StyledText("\(Int(value)) \(unitData.unitName(for: value))",
                                   textStyle: .subtitle,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .leading)
                        .opacity(0.5)
                    }
                }
            }
            .padding(.horizontal, 16.0)
            
            SmallLineGraphView()
                .environmentObject(graphModel)
                .drawingGroup()
                
        }
        .padding(.vertical, 16.0)
        .background(
            Rectangle()
                .fill(Color(UIColor.withStyle(.white).cgColor))
        )
        .roundedCorners(radius: 30.0)
        .styledShadow()
        .aspectRatio(1.0, contentMode: .fit)
    }
}

struct ActivitySingleLineTileView_Previews: PreviewProvider {
    private static let model: SmallLineGraphModel = SmallLineGraphModel(
        points: [
            .init(x: 0.0, y: 0.2),
            .init(x: 0.5, y: 0.5),
            .init(x: 0.8, y: 1.2)
        ],
        interpolationMode: .linear
    )
    
    static var previews: some View {
        ActivitySingleLineTileView(
            image: UIImage(named: "heartSolid")!,
            headerText: "HRV",
            unitData: nil
        )
        .environmentObject(model)
    }
}

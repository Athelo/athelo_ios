//
//  ActivitySummaryTileView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import SwiftUI

struct ActivitySingleColumnTileView: View {    
    @EnvironmentObject var graphModel: SmallColumnGraphModel
    
    let image: UIImage
    let headerText: String
    let unitData: UnitNameData?
    let displayedValueConverter: ((Double) -> Double)?
    
    init(image: UIImage, headerText: String, unitData: UnitNameData?, displayedValueConverter: ((Double) -> Double)? = nil) {
        self.image = image
        self.headerText = headerText
        self.unitData = unitData
        self.displayedValueConverter = displayedValueConverter
    }
    
    private var displayedValue: Double? {
        guard let value = graphModel.items.last?.value else {
            return nil
        }
        
        return displayedValueConverter?(value) ?? value
    }
    
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
                       let value = displayedValue {
                        StyledText("\(Int(value)) \(unitData.unitName(for: value))",
                                   textStyle: .subtitle,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .leading)
                        .opacity(0.5)
                    }
                }
            }
            
            SmallColumnGraphView()
                .environmentObject(graphModel)
                .drawingGroup()
                
        }
        .padding(16.0)
        .background(
            Rectangle()
                .fill(Color(UIColor.withStyle(.white).cgColor))
        )
        .roundedCorners(radius: 30.0)
        .styledShadow()
        .aspectRatio(1.0, contentMode: .fit)
    }
}

struct ActivitySingleColumnTileView_Previews: PreviewProvider {
    private static let graphModel = SmallColumnGraphModel(items: (0...6).map({
        GraphColumnItemData(id: $0, color: .withStyle(.lightOlivaceous), value: .random(in: 0.0...5.0), label: nil)
    }))
    
    static var previews: some View {
        ActivitySingleColumnTileView(
            image: UIImage(named: "gymSolid")!,
            headerText: "Activity",
            unitData: .init(plural: "minutes", short: "min", singular: "minute")
        )
        .environmentObject(graphModel)
    }
}

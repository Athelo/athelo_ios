//
//  GraphVerticalLegendView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphVerticalLegendView: View {
    @EnvironmentObject var model: GraphLegendItemsModel
    
    var body: some View {
        GeometryReader { geometry in
            let stepSize = geometry.size.height / max(1.0, CGFloat(model.legendItems.count - 1))
            
            ForEach(model.legendItems) { item in
                let itemIndex = model.legendItems.firstIndex(where: { $0.id == item.id }) ?? 0
                let yOffset = CGFloat(itemIndex) * stepSize
                
                StyledText(item.name,
                           textStyle: .legend,
                           colorStyle: .gray,
                           alignment: .center)
                .position(x: geometry.size.width / 2.0, y: geometry.size.height - yOffset)
            }
        }
    }
}

struct GraphVerticalLegendView_Previews: PreviewProvider {
    private static let model = GraphLegendItemsModel(legendItems: Array(0...9).enumerated().map({
        GraphLegendItemData(id: $0.offset, name: "\($0.element)")
    }))
    
    static var previews: some View {
        GraphVerticalLegendView()
            .environmentObject(model)
    }
}

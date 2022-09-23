//
//  GridHorizontalGridView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import SwiftUI

struct GraphHorizontalGridView: View {
    @EnvironmentObject var model: GraphLegendItemsModel
    
    var body: some View {
        GeometryReader { geometry in
            let stepSize = geometry.size.height / max(1.0, CGFloat(model.legendItems.count - 1))
            
            ForEach(model.legendItems) { item in
                let itemIndex = model.legendItems.firstIndex(where: { $0.id == item.id }) ?? 0
                let itemColor = Color((itemIndex == 0 ? .clear : GraphUtils.gridColor.withAlphaComponent(0.2)).cgColor)
                
                let yOffset = geometry.size.height - CGFloat(itemIndex) * stepSize
                
                Path { path in
                    path.move(to: .init(x: 0.0, y: yOffset))
                    path.addLine(to: .init(x: geometry.size.width, y: yOffset))
                }
                .stroke(itemColor, style: GraphUtils.gridStrokeStyle)
            }
        }
    }
}

struct GridHorizontalGridView_Previews: PreviewProvider {
    private static let model = GraphLegendItemsModel(legendItems: Array(0...9).enumerated().map({
        GraphLegendItemData(id: $0.offset, name: "\($0.element)")
    }))
    
    static var previews: some View {
        GraphHorizontalGridView()
            .environmentObject(model)
    }
}

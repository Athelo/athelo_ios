//
//  GraphHorizontalLegendView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphHorizontalLegendView: View {
    enum Spread {
        case absolute
        case byItemSize
    }
    
    @EnvironmentObject var model: GraphLegendItemsModel
    
    private let spread: Spread
    
    init(spread: Spread = .byItemSize) {
        self.spread = spread
    }
    
    private var spacingGap: Double {
        model.spacingGap
    }
    
    var body: some View {
        GeometryReader { geometry in
            let itemSize = singleItemSize(inside: geometry)
            let gapSize = itemGap(inside: geometry)
            
            ForEach(model.legendItems) { item in
                let itemIndex = model.legendItems.firstIndex(where: { $0.id == item.id }) ?? 0
                let xOffset = xOffset(at: itemIndex, itemSize: itemSize, gapSize: gapSize)

                StyledText(item.name,
                           textStyle: .legend,
                           colorStyle: .gray,
                           alignment: .center)
                .position(x: xOffset, y: geometry.size.height / 2.0)
            }
        }
    }
    
    private func singleItemSize(inside geometry: GeometryProxy) -> CGFloat {
        switch spread {
        case .absolute:
            return 0.0
        case .byItemSize:
            return geometry.size.width * (1 - spacingGap) / max(1.0, CGFloat(model.legendItems.count))
        }
    }
    
    private func itemGap(inside geometry: GeometryProxy) -> CGFloat {
        switch spread {
        case .absolute:
            return geometry.size.width / max(1.0, CGFloat(model.legendItems.count - 1))
        case .byItemSize:
            return geometry.size.width * spacingGap / max(1.0, CGFloat(model.legendItems.count - 1))
        }
    }
    
    private func gridItems(inside geometry: GeometryProxy) -> [GridItem] {
        let spaceBetweenItems = (geometry.size.width * spacingGap) / max(1.0, CGFloat(model.legendItems.count - 1))
        
        return model.legendItems.map({ _ in .init(.flexible(), spacing: spaceBetweenItems, alignment: .bottom) })
    }
    
    private func xOffset(at index: Int, itemSize: CGFloat, gapSize: CGFloat) -> CGFloat {
        switch spread {
        case .absolute:
            return gapSize * CGFloat(index)
        case .byItemSize:
            return itemSize / 2.0 + (itemSize + gapSize) * CGFloat(index)
        }
    }
}

struct GraphHorizontalLegendView_Previews: PreviewProvider {
    private static let model = GraphLegendItemsModel(legendItems: Calendar.current.shortWeekdaySymbols.enumerated().map({
        GraphLegendItemData(id: $0.offset, name: $0.element)
    }))
    
    static var previews: some View {
        GraphHorizontalLegendView(spread: .absolute)
            .environmentObject(model)
            .background(Rectangle().fill(.black.opacity(0.2)))
            .padding(.horizontal, 24.0)
    }
}

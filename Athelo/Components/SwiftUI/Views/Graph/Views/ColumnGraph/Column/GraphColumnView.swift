//
//  GraphColumnView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphColumnView: View {
    let columnItems: [GraphColumnItemData]
    let backgroundGradientColors: [UIColor]
    let maxValue: Double
    
    private let borderOffset: CGFloat = 4.0
    private let widthFactor: CGFloat = 0.875
    
    private var totalValue: CGFloat {
        columnItems.reduce(0.0) { partialResult, column in
            partialResult + column.value
        }
    }
    
    init(columnItems: [GraphColumnItemData], backgroundGradientColors: [UIColor] = [.clear], maxValue: Double = 0.0) {
        self.columnItems = columnItems
        self.backgroundGradientColors = backgroundGradientColors
        self.maxValue = maxValue
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(
                        .linearGradient(colors: backgroundGradientColors.map({ Color($0.cgColor) }),
                                        startPoint: .bottom,
                                        endPoint: .top)
                    )
                    .frame(width: (geometry.size.width * widthFactor), height: containerHeight(in: geometry), alignment: .center)
                    .roundedCorners(radius: 8.0, corners: [.topLeft, .topRight])
                    .position(position(in: geometry))
                
                VStack(spacing: 0.0) {
                    ForEach(columnItems.reversed()) { item in
                        StyledText(item.label ?? "",
                                   textStyle: .legend,
                                   colorStyle: item.labelColorStyle)
                        .frame(width: max(0.0, (geometry.size.width * widthFactor) - borderOffset), height: height(for: item, geometry: geometry), alignment: .center)
                        .background(
                            Rectangle()
                                .fill(Color(item.color.cgColor))
                        )
                    }
                }
                .roundedCorners(radius: 8.0, corners: [.topLeft, .topRight])
                .frame(width: max(0.0, (geometry.size.width * widthFactor) - borderOffset), alignment: .center)
                .position(position(in: geometry, yOffset: 1.0))
            }
            .opacity(totalValue > 0.0 ? 1.0 : 0.0)
        }
    }
    
    private func position(in geometry: GeometryProxy, yOffset: CGFloat = 0.0) -> CGPoint {
        .init(x: geometry.size.width / 2.0, y: geometry.size.height - containerHeight(in: geometry) / 2.0 + yOffset)
    }
    
    private func containerHeight(in geometry: GeometryProxy) -> CGFloat {
        guard maxValue > totalValue, maxValue > 0.0 else {
            return geometry.size.height
        }
        
        return totalValue / maxValue * geometry.size.height
    }
    
    private func height(for item: GraphColumnItemData, geometry: GeometryProxy) -> CGFloat {
        return max(0.0, max(0.0, containerHeight(in: geometry) - borderOffset / 2.0) * (item.value / totalValue))
    }
}

struct GraphColumnView_Previews: PreviewProvider {
    static var previews: some View {
        GraphColumnView(columnItems: [
            .init(id: 1, color: .red, value: 3.0, label: "1.0"),
            .init(id: 2, color: .blue, value: 2.0, label: ""),
            .init(id: 3, color: .brown, value: 2.6, label: "3.0")
        ])
    }
}

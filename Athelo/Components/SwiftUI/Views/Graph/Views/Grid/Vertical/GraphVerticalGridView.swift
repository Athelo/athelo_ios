//
//  GraphColumnGridView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphVerticalGridView: View {
    enum DrawingRule {
        case all
        case constant(Int)
        case monthGaps
    }
    
    enum Spread {
        case absolute
        case byItemSize
    }
    
    @Binding var columnCount: Int
    @Binding var drawingRule: DrawingRule
    @Binding var gridHorizontalOffset: Double
    @Binding var itemGap: Double
    
    let spread: Spread
        
    init(columnCount: Binding<Int>, drawingRule: Binding<DrawingRule> = .constant(.all), itemGap: Binding<Double> = .constant(0.25), gridHorizontalOffset: Binding<Double> = .constant(0.0), spread: Spread = .byItemSize) {
        self._columnCount = columnCount
        self._drawingRule = drawingRule
        self._gridHorizontalOffset = gridHorizontalOffset
        self._itemGap = itemGap
        
        self.spread = spread
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    path.move(to: .init(x: 0.0, y: .topLineOffset))
                    path.addLine(to: .init(x: 0.0, y: geometry.size.height))
                    path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
                }
                .stroke(Color(UIColor.withStyle(.gray).cgColor).opacity(0.2), style: .init(lineWidth: 2.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [], dashPhase: 0.0))
                
                ForEach(drawnColumns(), id: \.self) { column in
                    columnPath(column: column, geometry: geometry)
                }
            }
        }
    }
    
    private func drawnColumns() -> [Int] {
        let columnCount = max(1, columnCount)
        
        switch drawingRule {
        case .all:
            return Array(0...columnCount - 1)
        case .constant(let gap):
            return Array(stride(from: 0, through: columnCount - 1, by: gap))
        case .monthGaps:
            var drawnColumns: [Int] = []

            for column in 0...(columnCount - 1) {
                if column == 0 || ((column + 1) % 5 == 0) {
                    drawnColumns.append(column)
                }
            }
            
            return drawnColumns
        }
    }
    
    @ViewBuilder
    private func columnPath(column: Int, geometry: GeometryProxy) -> some View {
        switch spread {
        case .absolute:
            absoluteColumnPath(column: column, geometry: geometry)
        case .byItemSize:
            itemSizeBasedColumnPath(column: column, geometry: geometry)
        }
    }
    
    @ViewBuilder
    private func absoluteColumnPath(column: Int, geometry: GeometryProxy) -> some View {
        let contentWidth = max(0.0, geometry.size.width - gridHorizontalOffset * 2.0)
        let spaceBetweenItems = contentWidth / max(1.0, CGFloat(columnCount - 1))
        let shouldHideGridLine = column == 0 && gridHorizontalOffset.isZero
        let color = shouldHideGridLine ? Color.clear : Color(GraphUtils.gridColor.cgColor)
        
        let xPos = gridHorizontalOffset + spaceBetweenItems * CGFloat(column)
        
        let startPoint = CGPoint(x: xPos, y: .topLineOffset)
        let endPoint = CGPoint(x: xPos, y: geometry.size.height)
        
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(color, style: GraphUtils.gridStrokeStyle)
    }
    
    @ViewBuilder
    private func itemSizeBasedColumnPath(column: Int, geometry: GeometryProxy) -> some View {
        let columnCount = max(1, columnCount)
        let contentWidth: CGFloat = max(0.0, geometry.size.width - (gridHorizontalOffset * 2.0))
        let spaceBetweenItems: CGFloat = (contentWidth * itemGap) / max(1.0, CGFloat(columnCount - 1))
        let columnWidth: CGFloat = (contentWidth - spaceBetweenItems * CGFloat(columnCount - 1)) / CGFloat(columnCount)
        
        let xPos = gridHorizontalOffset + (columnWidth / 2.0) + (spaceBetweenItems + columnWidth) * CGFloat(column)
        
        let startPoint = CGPoint(x: xPos, y: .topLineOffset)
        let endPoint = CGPoint(x: xPos, y: geometry.size.height)
        
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(Color(GraphUtils.gridColor.cgColor), style: .init(lineWidth: 1.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [10.0, 10.0], dashPhase: 0.0))
    }
}

struct GraphColumnGridView_Previews: PreviewProvider {
    static var previews: some View {
        GraphVerticalGridView(columnCount: .constant(7), spread: .absolute)
    }
}

private extension CGFloat {
    static var topLineOffset: Double {
        -6.0
    }
}

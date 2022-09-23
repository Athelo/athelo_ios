//
//  GraphColumnGridView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphColumnGridView: View {
    enum DrawingRule {
        case all
        case monthGaps
    }
    
    @Binding var columnCount: Int
    let drawingRule: DrawingRule
    
    @ViewBuilder
    private func columnPath(column: Int, geometry: GeometryProxy) -> some View {
        let columnCount = max(1, columnCount)
        let spaceBetweenItems = (geometry.size.width * 0.25) / max(1.0, CGFloat(columnCount - 1))
        let columnWidth = (geometry.size.width - spaceBetweenItems * CGFloat(columnCount - 1)) / CGFloat(columnCount)
        
        let xPos = columnWidth / 2.0 + (spaceBetweenItems + columnWidth) * CGFloat(column - 1)
        
        let startPoint = CGPoint(x: xPos, y: 0.0)
        let endPoint = CGPoint(x: xPos, y: geometry.size.height)
        
        Path { path in
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        .stroke(Color(UIColor.withStyle(.lightGray).cgColor), style: .init(lineWidth: 1.0, lineCap: .round, lineJoin: .bevel, miterLimit: 0.0, dash: [10.0, 10.0], dashPhase: 0.0))
    }
    
    init(columnCount: Binding<Int>, drawingRule: DrawingRule = .all) {
        self._columnCount = columnCount
        self.drawingRule = drawingRule
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    path.move(to: .init(x: 0.0, y: 0.0))
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
            return Array(1...columnCount)
        case .monthGaps:
            var drawnColumns: [Int] = []
            for column in 1...columnCount {
                if column == 1 || column == columnCount || ((column % 5 == 0) && (column < columnCount - 1)) {
                    drawnColumns.append(column)
                }
            }
            
            return drawnColumns
        }
    }
}

struct GraphColumnGridView_Previews: PreviewProvider {
    static var previews: some View {
        GraphColumnGridView(columnCount: .constant(7))
    }
}

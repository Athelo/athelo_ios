//
//  GraphColumnChartView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/07/2022.
//

import SwiftUI

struct GraphColumnChartView: View {
    typealias GridDrawingRule = GraphVerticalGridView.DrawingRule
    
    @ObservedObject private(set) var model: GraphColumnChartModel
    
    @State private var isDragging: Bool = false
    @State private var selectedColumn: GraphColumnData?
    @State private var overlayPosition: CGPoint = .zero
    
    @State private var selectedColumnLabel: String?
    @State private var selectedColumnSecondaryLabel: String?
    
    private let columnBorderGradientColors: [UIColor]
    
    init(model: GraphColumnChartModel, columnBorderGradientColors: [UIColor] = [.withStyle(.lightOlivaceous), .withStyle(.olivaceous)]) {
        self.model = model
        self.columnBorderGradientColors = columnBorderGradientColors
    }
    
    private var columns: [GraphColumnData] {
        model.data.columns
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let legendTitle = model.data.legendLabel, !legendTitle.isEmpty {
                StyledText(legendTitle,
                           textStyle: .legend,
                           colorStyle: .lightGray,
                           alignment: .leading)
                .padding(.bottom, 8.0)
            }
            
            HStack(spacing: 0.0) {
                GraphVerticalLegendView()
                    .frame(width: model.legendWidth, alignment: .center)
                    .environmentObject(model.verticalItemsModel)
                    .animation(.default)
                
                ZStack {
                    GraphVerticalGridView(
                        columnCount: $model.columnCount,
                        drawingRule: $model.gridDrawingRule,
                        itemGap: $model.spacingGap,
                        gridHorizontalOffset: $model.horizontalGridOffset
                    )
                    
                    if model.displaysHorizontalGrid {
                        GraphHorizontalGridView()
                            .environmentObject(model.verticalItemsModel)
                    }
                    
                    HStack(spacing: 0.0) {
                        Spacer(minLength: model.horizontalGridOffset)
                        
                        ZStack {
                            GeometryReader { geometry in
                                LazyVGrid(columns: gridItems(inside: geometry.size), alignment: .center) {
                                    ForEach(columns) { column in
                                        GraphColumnView(columnItems: column.items, backgroundGradientColors: columnBorderGradientColors, maxValue: model.maxColumnValue)
                                        .frame(height: geometry.size.height)
                                    }
                                }
                                .animation(.default)
                                .frame(height: geometry.size.height, alignment: .bottom)
                            }
                            
                            GraphSelectedItemInfoView(
                                label: $selectedColumnLabel,
                                secondaryLabel: $selectedColumnSecondaryLabel
                            )
                            .position(x: overlayPosition.x, y: overlayPosition.y)
                            .opacity(selectedColumn != nil ? 1.0 : 0.0)
                            .animation(.default)
                            
                            TapOverlayView(callback: { point, size in
                                handleTap(in: point, size: size)
                            }, dragStateCallback: { isDragging in
                                self.isDragging = isDragging
                            })
                        }
                        
                        Spacer(minLength: model.horizontalGridOffset)
                    }
                }
            }
            
            HStack(spacing: 0.0) {
                Spacer(minLength: model.legendWidth + model.horizontalGridOffset)
                
                GraphHorizontalLegendView()
                    .frame(height: 20.0, alignment: .top)
                    .environmentObject(model.horizontalItemsModel)
                    .animation(.default)
                
                Spacer(minLength: model.horizontalGridOffset)
            }
        }
        .onChange(of: model.data.columns) { _ in
            selectedColumn = nil
        }
        .onChange(of: selectedColumn) { newValue in
            selectedColumnLabel = newValue?.label
            selectedColumnSecondaryLabel = newValue?.secondaryLabel
        }
    }
    
    private func columnData(at point: CGPoint, in size: CGSize) -> GraphColumnData? {
        let columnGap = columnSpacing(inside: size)
        let itemSize = (size.width - (columnGap * max(0.0, CGFloat(columns.count - 1)))) / max(1.0, CGFloat(columns.count))
        
        var index: Int = 0
        var offset: CGFloat = 0.0
        
        while offset <= size.width {
            if (offset...(offset + itemSize)) ~= point.x {
                guard let column = columns[safe: index] else {
                    return nil
                }
                
                let columnHeight = height(for: column, in: size)
                let columnMinY = size.height - columnHeight
                
                return point.y >= columnMinY ? column : nil
            }
            
            offset += itemSize + columnGap
            index += 1
        }
        
        return nil
    }
    
    private func columnSpacing(inside size: CGSize) -> CGFloat {
        (size.width * model.spacingGap) / max(1.0, CGFloat(columns.count - 1))
    }
    
    private func handleTap(in point: CGPoint, size: CGSize) {
        let columnData = columnData(at: point, in: size)
        if isDragging, columnData == nil {
            return
        }
        
        selectedColumn = columnData
        
        guard let selectedColumn = selectedColumn else {
            return
        }
        
        var targetCoordinates = point
        let overlaySize = GraphUtils.overlaySize(for: selectedColumn.label, secondaryLabel: selectedColumn.secondaryLabel)
        
        let columnHeight = height(for: selectedColumn, in: size)
        targetCoordinates.y = size.height - (columnHeight + overlaySize.height / 2.0 + 4.0)
        targetCoordinates = GraphUtils.adjustOverlayCenterPoint(targetCoordinates, inside: size, overlaySize: overlaySize)
        
        overlayPosition = targetCoordinates
    }
    
    private func height(for columnData: GraphColumnData, in size: CGSize) -> CGFloat {
        let maxValue = model.maxColumnValue
        let columnValue = columnData.items.map({ $0.value }).reduce(0.0, +)
        
        return max(1.0, size.height * columnValue / maxValue)
    }
    
    private func gridItems(inside size: CGSize) -> [GridItem] {
//        let spaceBetweenItems = (size.width * 0.05) / max(1.0, CGFloat(columns.count - 1))
        
        return columns.map({ _ in .init(.flexible(), spacing: columnSpacing(inside: size), alignment: .bottom) })
    }
}

struct GraphColumnChartView_Previews: PreviewProvider {
    private static let model = GraphColumnChartModel(data: .init(columns: [], horizontalLegendItems: [], legendLabel: "Hours"))
    
    static var previews: some View {
        VStack(spacing: 40.0) {
            GraphColumnChartView(model: model)
            
            Button {
                randomize(model: model)
            } label: {
                Text("Randomize!")
            }
        }
    }
    
    private static func randomize(model: GraphColumnChartModel) {
        func randomItems() -> [GraphColumnItemData] {
            (0...2).map({ _ in Int.random(in: 0...3) }).enumerated().map({ (idx, item) -> GraphColumnItemData in
                switch idx {
                case 0:
                    return .init(id: idx, color: SleepPhase.rem.color, value: CGFloat(item), label: "\(item).0", labelColorStyle: SleepPhase.rem.labelColorStyle)
                case 1:
                    return .init(id: idx, color: SleepPhase.deep.color, value: CGFloat(item), label: "\(item).0", labelColorStyle: SleepPhase.deep.labelColorStyle)
                default:
                    return .init(id: idx, color: SleepPhase.light.color, value: CGFloat(item), label: "\(item).0", labelColorStyle: SleepPhase.light.labelColorStyle)
                }
            })
        }
        
        let columns: [GraphColumnData] = (0...Int.random(in: 6...30)).enumerated().map({
            GraphColumnData(
                id: $0.offset,
                items: randomItems(),
                label: "\($0)",
                secondaryLabel: Bool.random() ? Date().dateByAdding(-$0.offset, .day).date.weekdayName(.standaloneShort) : nil)
        })
        
        let legend: [GraphLegendItemData] = Calendar.current.shortWeekdaySymbols.enumerated().map({
            GraphLegendItemData(id: $0.offset, name: $0.element)
        })
        
        model.updateData(.init(columns: columns, horizontalLegendItems: legend, legendLabel: "Hours"))
    }
}

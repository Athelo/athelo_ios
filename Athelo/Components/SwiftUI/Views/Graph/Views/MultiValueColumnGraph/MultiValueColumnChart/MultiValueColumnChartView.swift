//
//  MultiValueColumnGraphView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import SwiftUI

struct MultiValueColumnChartView: View {
    @ObservedObject var model: MultiValueColumnChartModel
    
    @State private var isDragging: Bool = false
    @State private var selectedColumn: GraphMultiValueColumnChartData?
    @State private var overlayPosition: CGPoint = .zero
    
    @State private var selectedColumnLabel: String?
    @State private var selectedColumnSecondaryLabel: String?
    
    private var items: [GraphMultiValueColumnChartData] {
        model.items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            if let legendTitle = model.legendLabel, !legendTitle.isEmpty {
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
                        gridHorizontalOffset: $model.gridHorizontalOffset
                    )
                    
                    if model.displaysHorizontalGrid {
                        GraphHorizontalGridView()
                            .environmentObject(model.verticalItemsModel)
                    }
                    
                    HStack(spacing: 0.0) {
                        Spacer(minLength: model.gridHorizontalOffset)
                        
                        ZStack {
                            GeometryReader { geometry in
                                LazyVGrid(columns: gridItems(inside: geometry)) {
                                    ForEach(items) { item in
                                        MultiValueColumnView(data: item)
                                            .frame(height: geometry.size.height, alignment: .center)
                                    }
                                }
                                .animation(.interactiveSpring(), value: items)
                                .frame(height: geometry.size.height, alignment: .center)
                            }
                            .drawingGroup()
                            
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
                        
                        Spacer(minLength: model.gridHorizontalOffset)
                    }
                }
            }
            
            HStack(spacing: 0.0) {
                Spacer(minLength: model.legendWidth + model.gridHorizontalOffset)
                
                GraphHorizontalLegendView(spread: .byItemSize)
                    .frame(height: 20.0, alignment: .top)
                    .environmentObject(model.horizontalItemsModel)
                    .animation(.default)
                
                Spacer(minLength: model.gridHorizontalOffset)
            }
        }
        .onChange(of: model.items) { newValue in
            selectedColumn = nil
        }
        .onChange(of: selectedColumn) { newValue in
            selectedColumnLabel = newValue?.label
            selectedColumnSecondaryLabel = newValue?.secondaryLabel
        }
    }

    private func columnData(at point: CGPoint, in size: CGSize) -> (column: GraphMultiValueColumnChartData, minY: CGFloat)? {
        let gap = itemSpacing(inside: size)
        let itemSize = (size.width - (gap * max(0.0, CGFloat(items.count - 1)))) / max(1.0, CGFloat(items.count))
        
        var index: Int = 0
        var offset: CGFloat = 0.0
        
        while offset <= size.width {
            if (offset...(offset + itemSize)) ~= point.x {
                guard let item = items[safe: index],
                      let minValue = item.values.min(),
                      let maxValue = item.values.max() else {
                    return nil
                }
                
                let distance = item.maxValue - item.minValue
                let columnMinY: CGFloat = (distance - maxValue) / distance * size.height
                let columnMaxY: CGFloat = (distance - minValue) / distance * size.height
                
                return columnMinY...columnMaxY ~= point.y ? (item, columnMinY) : nil
            }
            
            offset += itemSize + gap
            index += 1
        }
        
        return nil
    }
    
    private func gridItems(inside geometry: GeometryProxy) -> [GridItem] {
        return model.items.map({ _ in .init(.flexible(), spacing: itemSpacing(inside: geometry.size), alignment: .center) })
    }
    
    private func handleTap(in point: CGPoint, size: CGSize) {
        let columnSearchResult = columnData(at: point, in: size)
        if isDragging, columnSearchResult?.column == nil {
            return
        }
        
        selectedColumn = columnSearchResult?.column
        
        guard let selectedColumn = columnSearchResult?.column,
              let columnMinY = columnSearchResult?.minY else {
            return
        }

        var targetCoordinates = point
        let overlaySize = GraphUtils.overlaySize(for: selectedColumn.label, secondaryLabel: selectedColumn.secondaryLabel)
        
        targetCoordinates.y = columnMinY - overlaySize.height / 2.0
        targetCoordinates = GraphUtils.adjustOverlayCenterPoint(targetCoordinates, inside: size, overlaySize: overlaySize)
        
        overlayPosition = targetCoordinates
    }
    
    private func itemSpacing(inside size: CGSize) -> CGFloat {
        max(0.0, floor((size.width * model.spacingGap) / max(1.0, CGFloat(model.items.count - 1))))
    }
}

struct MultiValueColumnChartView_Previews: PreviewProvider {
    static let model: MultiValueColumnChartModel = {
        let model = MultiValueColumnChartModel(items: (0...20).map({ .sample(in: 50...140, id: $0) }))
                    
        model.updateLegendLabel("bpm")
        model.updateHorizontalLegendItems(
            (0...20).map({ .init(id: $0, name: "\(Int($0))" ) })
        )
        
        return model
    }()
    
    static var previews: some View {
        VStack {
            MultiValueColumnChartView(model: model)
            
            Divider()
            
            Button {
                model.updateItems(
                    (0...20).map({ .sample(in: 50...140, id: $0) })
                )
                model.updateHorizontalLegendItems(
                    (0...20).map({ .init(id: $0, name: "\(Int($0))" ) })
                )
            } label: {
                Text("Randomize items!")
            }
        }
    }
}

private extension GraphMultiValueColumnChartData {
    static func sample(in range: ClosedRange<Double>, id: Int = 1) -> GraphMultiValueColumnChartData {
        GraphMultiValueColumnChartData(
            id: id,
            values: (0...9).map({ _ in Double.random(in: range) + Double.random(in: -50...10) }),
            minValue: 0.0,
            maxValue: min(150.0, range.upperBound + 25.0)
        )
    }
}

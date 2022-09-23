//
//  MultiValueColumnView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/08/2022.
//

import SwiftUI

private struct GraphMultiValueItemData: Equatable, Hashable, Identifiable {
    let id: Int
    
    let lowerBound: CGFloat
    let upperBound: CGFloat
}

struct MultiValueColumnView: View {
    let multiValueColumnData: GraphMultiValueColumnChartData
    
    init(data: GraphMultiValueColumnChartData) {
        self.multiValueColumnData = data
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items(inside: geometry.size)) { item in
                    pill(for: item, inside: geometry.size)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
            .animation(.spring(), value: multiValueColumnData)
        }
    }
    
    @ViewBuilder
    private func pill(for item: GraphMultiValueItemData, inside size: CGSize) -> some View {
        let range = multiValueColumnData.maxValue - multiValueColumnData.minValue
        let minBoundPosition = (multiValueColumnData.maxValue - item.lowerBound) / range
        let maxBoundPosition = (multiValueColumnData.maxValue - item.upperBound) / range
        let shouldBeHidden = item.lowerBound == multiValueColumnData.minValue && item.upperBound == multiValueColumnData.minValue
        
        let centerY = (minBoundPosition + maxBoundPosition) / 2.0 * size.height
        let height = max(size.width, abs(maxBoundPosition - minBoundPosition) * size.height)
        
        RoundedRectangle(cornerRadius: size.width / 2.0)
            .fill(Color((shouldBeHidden ? .clear : UIColor.withStyle(.lightOlivaceous)).cgColor))
            .frame(width: size.width, height: height, alignment: .center)
            .position(x: size.width / 2.0, y: centerY)
    }
    
    private func items(inside size: CGSize) -> [GraphMultiValueItemData] {
        func pixelPosition(of value: Double) -> CGFloat {
            (multiValueColumnData.maxValue - value) / (multiValueColumnData.maxValue - multiValueColumnData.minValue) * size.height
        }
        
        let range = multiValueColumnData.maxValue - multiValueColumnData.minValue
        let valuePerPixel = range / size.height
        let widthValue = size.width * valuePerPixel
        
        var clusters: [[Double]] = []
        var clusterValues: [Double] = []
        
        let sortedValues = multiValueColumnData.values.sorted()
        
        sortedValues.enumerated().forEach({
            if clusterValues.isEmpty {
                clusterValues.append($0.element)
            } else {
                clusterValues.append($0.element)
                
                if let nextValue = sortedValues[safe: $0.offset + 1], abs(pixelPosition(of: nextValue) - pixelPosition(of: $0.element)) > ceil(widthValue * 5.0) {
                    clusters.append(clusterValues)
                    clusterValues.removeAll()
                }
            }
        })
        
        if !clusterValues.isEmpty {
            clusters.append(clusterValues)
        }
        
        var index: Int = 0
        var items: [GraphMultiValueItemData] = []
        
        for cluster in clusters {
            if let minBound = cluster.min(),
               let maxBound = cluster.max() {
                items.append(.init(id: index, lowerBound: minBound, upperBound: maxBound))
                index += 1
            }
        }
        
        return items
    }
}

struct MultiValueColumnView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: geometry.size.width / 7.0 * 3.0)
                
                MultiValueColumnView(data: .sample(in: 0...100))
                
                Spacer(minLength: geometry.size.width / 7.0 * 3.0)
            }
        }
    }
}

private extension GraphMultiValueColumnChartData {
    static func sample(in range: ClosedRange<Double>, id: Int = 1) -> GraphMultiValueColumnChartData {
        GraphMultiValueColumnChartData(
            id: id,
            values: (0...9).map({ _ in Double.random(in: range) }),
            minValue: range.lowerBound - 25.0,
            maxValue: range.upperBound + 25.0
        )
    }
}

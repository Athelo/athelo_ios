//
//  SmallColumnGraphView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import SwiftUI

struct SmallColumnGraphView: View {
    @EnvironmentObject var model: SmallColumnGraphModel
    
    var items: [GraphColumnItemData] {
        model.items
    }
    
    var maxValue: CGFloat {
        items.map({ $0.value }).max() ?? 0.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: gridItems(inside: geometry)) {
                ForEach(items) { item in
                    SmallColumnGraphColumnView(item: item, maxValue: maxValue)
                        .frame(height: geometry.size.height, alignment: .center)
                }
            }
            .animation(.default, value: items)
        }
    }
    
    func gridItems(inside geometry: GeometryProxy) -> [GridItem] {
        let itemGap = itemGap(inside: geometry)
        
        return items.map { _ in
            GridItem(.flexible(), spacing: itemGap)
        }
    }
    
    func itemGap(inside geometry: GeometryProxy) -> CGFloat {
        let gapSections = items.count * 2
        
        return floor(geometry.size.width / CGFloat(gapSections))
    }
}

struct SmallColumnGraphView_Previews: PreviewProvider {
    private static let model = SmallColumnGraphModel(items: randomizedItems())
    
    static var previews: some View {
        VStack {
            SmallColumnGraphView()
                .environmentObject(model)
            
            Button {
                model.updateItems(randomizedItems())
            } label: {
                Text("Randomize items")
            }
        }
    }
    
    private static func randomizedItems() -> [GraphColumnItemData] {
        (0...6).map({
            GraphColumnItemData(id: $0, color: .withStyle(.lightOlivaceous), value: .random(in: 0.0...5.0), label: nil)
        })
    }
}

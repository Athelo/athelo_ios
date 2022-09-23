//
//  SmallColumnGraphColumnView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/08/2022.
//

import SwiftUI

struct SmallColumnGraphColumnView: View {
    let item: GraphColumnItemData
    let maxValue: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color(item.color.cgColor).opacity(0.25))
                
                Rectangle()
                    .fill(Color(item.color.cgColor))
                    .frame(height: itemHeight(inside: geometry), alignment: .center)
                    .roundedCorners(radius: min(geometry.size.width, geometry.size.height) / 2.0)
                    .position(x: geometry.size.width / 2.0, y: yOffset(inside: geometry))
            }
            .roundedCorners(radius: min(geometry.size.width, geometry.size.height) / 2.0)
        }
    }
    
    func itemHeight(inside geometry: GeometryProxy) -> CGFloat {
        guard maxValue > 0.0 else {
            return 0.0
        }
        
        return item.value / maxValue * geometry.size.height
    }
    
    func yOffset(inside geometry: GeometryProxy) -> CGFloat {
        geometry.size.height - itemHeight(inside: geometry) / 2.0
    }
}

struct SmallColumnGraphColumnView_Previews: PreviewProvider {
    static var previews: some View {
        SmallColumnGraphColumnView(item: .init(id: 0, color: .withStyle(.lightOlivaceous), value: 2.0, label: nil), maxValue: 2.5)
    }
}

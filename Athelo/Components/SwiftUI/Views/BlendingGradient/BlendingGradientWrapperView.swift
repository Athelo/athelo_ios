//
//  BlendingGradientWrapperView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import Foundation
import SwiftUI

struct BlendingGradientWrapperView: UIViewRepresentable {
    let blendsFromTop: Bool
    
    func makeUIView(context: Context) -> BlendingGradientView {
        let view = BlendingGradientView()
        
        view.backgroundColor = .withStyle(.background)
        view.blendsFromTop = blendsFromTop
        
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return view
    }
    
    func updateUIView(_ uiView: BlendingGradientView, context: Context) {
        /* ... */
    }
}

//
//  FadingScrollView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 28/03/2023.
//

import SwiftUI

struct FadingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicator: Bool = true
    var gradientHeight: CGFloat = 24.0
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView(axes, showsIndicators: showsIndicator) {
                    content()
                        .frame(width: proxy.size.width)
                }
                .clipped()
                
                VStack {
                    BlendingGradientWrapperView(blendsFromTop: false)
                        .frame(height: gradientHeight)
                    
                    Spacer()
                    
                    BlendingGradientWrapperView(blendsFromTop: true)
                        .frame(height: gradientHeight)
                }
            }
        }
    }
}

struct FadingScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FadingScrollView() {
            Text(":)")
        }
    }
}

//
//  LoadMoreView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 27/07/2022.
//

import SwiftUI

struct LoadMoreView: UIViewRepresentable {
    func makeUIView(context: Context) -> LoadingView {
        LoadingView.init(frame: .zero)
    }
    
    func updateUIView(_ uiView: LoadingView, context: Context) {
        /* ... */
    }
}

struct LoadMoreView_Previews: PreviewProvider {
    static var previews: some View {
        LoadMoreView()
    }
}

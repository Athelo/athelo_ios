//
//  Size.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/03/2023.
//
// Based on: https://stackoverflow.com/questions/68842004/how-do-i-make-a-swiftui-scroll-view-shrink-to-content

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
    
    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }
}

extension View {
    func getSize(onSizeChange: @escaping (CGSize) -> ()) -> some View {
        self.modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                onSizeChange($0)
            }
    }
}

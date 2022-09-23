//
//  StyledShadow.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 20/06/2022.
//

import SwiftUI

struct StyledShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(UIColor.withStyle(.shadow).cgColor).opacity(0.2), radius: 16.0, x: 0.0, y: 5.0)
            .shadow(color: Color(UIColor.withStyle(.shadow).cgColor).opacity(0.08), radius: 18.0, x: 0.0, y: 10.0)
    }
}

extension View {
    func styledShadow() -> some View {
        modifier(StyledShadow())
    }
}

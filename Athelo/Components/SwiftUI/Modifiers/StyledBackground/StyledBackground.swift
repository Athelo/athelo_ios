//
//  StyledBackground.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 29/07/2022.
//

import SwiftUI

extension View {
    func styledBackground(_ color: UIColor = .clear, alignment: Alignment = .center) -> some View {
        return background(Rectangle().fill(Color(color.cgColor)), alignment: alignment)
    }
}

//
//  RoundedCorners.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/06/2022.
//

import SwiftUI

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: .init(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorners(radius: CGFloat, corners: UIRectCorner? = nil) -> some View {
        clipShape(RoundedCorners(radius: radius, corners: corners ?? .allCorners))
    }
}

//
//  CGPoint+Distance.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 11/08/2022.
//

import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        abs(hypot(x - point.x, y - point.y))
    }
}

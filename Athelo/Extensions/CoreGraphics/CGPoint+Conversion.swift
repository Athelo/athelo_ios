//
//  CGPoint+Conversions.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/08/2022.
//

import CoreGraphics
import Foundation

extension CGPoint {
    func toVector() -> CGVector {
        CGVector(dx: x, dy: y)
    }
}

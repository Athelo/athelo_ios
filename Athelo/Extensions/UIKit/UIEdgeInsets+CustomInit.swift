//
//  UIEdgeInsets+CustomInit.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    init(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        self.init(top: top ?? 0.0, left: left ?? 0.0, bottom: bottom ?? 0.0, right: right ?? 0.0)
    }

    init(horizontal: CGFloat? = nil, vertical: CGFloat? = nil) {
        self.init(top: vertical ?? 0.0, left: horizontal ?? 0.0, bottom: vertical ?? 0.0, right: horizontal ?? 0.0)
    }
}

//
//  UINavigationController+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

extension UINavigationController {
    /// Makes navigation bar translucent.
    ///
    /// Call to this method does the following to the owned `navigationBar` instance:
    /// * sets `isTranslucent` property to `true`.
    /// * sets backgroundImage for `default` metric to an empty `UIImage` instance.
    /// * sets `shadowImage` property to an empty `UIImage` instance.
    func makeNavigationBarTranslucent() {
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
    }
}

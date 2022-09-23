//
//  UIScrollView+RefreshControl.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import Foundation
import UIKit

extension UIScrollView {
    func addStyledRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .withStyle(.purple988098)
        
        self.refreshControl = refreshControl
    }
}

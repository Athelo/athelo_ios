//
//  UIViewController+SwiftUI.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 18/07/2022.
//

import Foundation
import SwiftUI
import UIKit

extension UIViewController {
    @discardableResult func embedView<V: View>(_ view: V, to subview: UIView) -> UIView? {
        guard subview.isDescendant(of: self.view) else {
            return nil
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        subview.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: subview.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: subview.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: subview.rightAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        return hostingController.view
    }
}

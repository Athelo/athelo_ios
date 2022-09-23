//
//  UIViewController+BackgroundGradient.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/06/2022.
//

import SwiftUI
import UIKit

extension UIViewController {
    @MainActor func displayBackgroundGradient(in subview: UIView? = nil, color: UIColor? = nil, imageData: BottomClippedGradientViewImageData? = nil) {
        var targetView = view
        
        if let subview = subview {
            guard subview.isDescendant(of: view) else {
                return
            }
            
            targetView = subview
        }
        
        guard let targetView = targetView else {
            return
        }
        
        let backgroundView = BottomClippedGradientView(color: color?.cgColor, imageData: imageData)
        let backgroundViewController = UIHostingController(rootView: backgroundView)
        
        backgroundViewController.view.translatesAutoresizingMaskIntoConstraints = false
        backgroundViewController.view.backgroundColor = .clear
        
        addChild(backgroundViewController)
        targetView.insertSubview(backgroundViewController.view, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundViewController.view.topAnchor.constraint(equalTo: targetView.topAnchor),
            backgroundViewController.view.bottomAnchor.constraint(equalTo: targetView.bottomAnchor),
            backgroundViewController.view.leftAnchor.constraint(equalTo: targetView.leftAnchor),
            backgroundViewController.view.rightAnchor.constraint(equalTo: targetView.rightAnchor)
        ])
        
        backgroundViewController.didMove(toParent: self)
    }
}

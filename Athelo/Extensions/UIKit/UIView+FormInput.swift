//
//  UIView+FormInput.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/09/2022.
//

import Foundation
import UIKit

extension UIViewController {
    func adjustFrameOfFormInputView(_ inputView: UIView, inRelationTo anchorTextField: FormTextField, inside containerView: UIView, of formScrollView: UIScrollView, estimatedComponentHeight: CGFloat, forceAppendOnTop: Bool = false) {
        let textFieldWindowFrame = containerView.convert(anchorTextField.frame, to: nil)
        let textFieldScrollViewFrame = containerView.convert(anchorTextField.frame, to: formScrollView)
        
        var shouldAppendInputBelowTextField: Bool = true
        let bottomYBoundary = AppRouter.current.window.bounds.maxY - (AppRouter.current.window.safeAreaInsets.bottom + 16.0)
        if forceAppendOnTop || textFieldWindowFrame.maxY + 8.0 + estimatedComponentHeight > bottomYBoundary {
            shouldAppendInputBelowTextField = false
        }
        
        if shouldAppendInputBelowTextField {
            inputView.frame = .init(origin: .init(x: textFieldScrollViewFrame.minX, y: textFieldScrollViewFrame.maxY + 16.0), size: .zero)
        } else {
            inputView.frame = .init(origin: .init(x: textFieldScrollViewFrame.minX, y: textFieldScrollViewFrame.minY - estimatedComponentHeight), size: .zero)
        }
        
        var activatedConstraints: [NSLayoutConstraint] = []
        activatedConstraints.append(contentsOf: [
            inputView.widthAnchor.constraint(equalTo: anchorTextField.widthAnchor),
            inputView.centerXAnchor.constraint(equalTo: anchorTextField.centerXAnchor)
        ])
        
        if shouldAppendInputBelowTextField {
            activatedConstraints.append(inputView.topAnchor.constraint(equalTo: anchorTextField.textFieldBottomAnchor, constant: 8.0))
        } else {
            activatedConstraints.append(anchorTextField.textFieldTopAnchor.constraint(equalTo: inputView.bottomAnchor, constant: 8.0))
        }
        
        NSLayoutConstraint.activate(activatedConstraints)
    }
}

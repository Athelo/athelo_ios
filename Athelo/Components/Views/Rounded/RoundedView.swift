//
//  RoundedView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 04/07/2022.
//

import UIKit

class RoundedView: UIView {
    // MARK: - Inspectables
    @IBInspectable var maxCornerRadius: CGFloat = 0.0 {
        didSet {
            updateCorners()
        }
    }
    
    // MARK: - View lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCorners()
    }
    
    // MARK: - Updates
    private func updateCorners() {
        layer.masksToBounds = true
        
        var targetCornerRadius = min(bounds.width, bounds.height) / 2.0
        if maxCornerRadius > 0.0 {
            targetCornerRadius = min(maxCornerRadius, targetCornerRadius)
        }
        
        layer.cornerRadius = targetCornerRadius
    }
}

//
//  BlendingGradientView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 08/07/2022.
//

import UIKit

final class BlendingGradientView: UIView {
    // MARK: - Inspectables
    @IBInspectable var blendsFromTop: Bool = true {
        didSet {
            updateBlendingMaskLayer(forced: true)
        }
    }
    
    @IBInspectable var fixedBlendHeight: Double = 0 {
        didSet {
            updateBlendingMaskLayer(forced: true)
        }
    }
    
    // MARK: - View lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBlendingMaskLayer()
    }
    
    // MARK: - Updates
    private func updateBlendingMaskLayer(forced: Bool = false) {
        if !forced, let currentLayer = layer.mask as? CAGradientLayer,
           __CGSizeEqualToSize(currentLayer.bounds.size, bounds.size) {
            return
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        gradientLayer.frame = bounds
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: blendsFromTop ? 0.0 : 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: blendsFromTop ? 1.0 : 0.0)
        
        var midLocation: Double
        if fixedBlendHeight > 0 {
            midLocation = max(0.0, min(1.0, fixedBlendHeight / bounds.size.height))
        } else {
            midLocation = max(0.2, min(1.0, 20.0 / bounds.size.height))
        }
        
        gradientLayer.locations = [0.0, NSNumber(value: midLocation), 1.0]
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor,
            UIColor.black.cgColor
        ]
        
        layer.mask = gradientLayer
    }
}

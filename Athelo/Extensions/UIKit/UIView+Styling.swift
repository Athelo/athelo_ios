//
//  UIView+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation
import UIKit

extension UIView {
    // MARK: - Constants
    private enum ShadowLayerNames: String {
        case innerShadowLayer
        case outerShadowLayer
    }
    
    // MARK: - Outlets
    private var innerShadowLayer: CAShapeLayer? {
        layer.sublayers?.first(where: { $0.name == ShadowLayerNames.innerShadowLayer.rawValue }) as? CAShapeLayer
    }
    
    private var outerShadowLayer: CAShapeLayer? {
        layer.sublayers?.first(where: { $0.name == ShadowLayerNames.outerShadowLayer.rawValue }) as? CAShapeLayer
    }
    
    // MARK: - Inspectables
    @IBInspectable var backgroundColorAlpha: CGFloat {
        get {
            backgroundColor?.cgColor.alpha ?? 0.0
        }
        set {
            backgroundColor = backgroundColor?.withAlphaComponent(max(0.0, min(1.0, newValue)))
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0.0
        }
    }
    
    // MARK: - Public API
    func updateStyledShadowPaths() {
        createInnerShadowPathIfNeeded()
        createOuterShadowPathIfNeeded()
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 20.0)
        
        innerShadowLayer?.shadowPath = path.cgPath
        outerShadowLayer?.shadowPath = path.cgPath
    }
    
    // MARK: - Updates
    private func createInnerShadowPathIfNeeded() {
        guard innerShadowLayer == nil else {
            return
        }
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.shadowColor = UIColor.withStyle(.shadow).cgColor
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        shadowLayer.shadowRadius = 16.0
        shadowLayer.name = ShadowLayerNames.innerShadowLayer.rawValue
        
        layer.addSublayer(shadowLayer)
    }
    
    private func createOuterShadowPathIfNeeded() {
        guard outerShadowLayer == nil else {
            return
        }
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.shadowColor = UIColor.withStyle(.shadow).cgColor
        shadowLayer.shadowOpacity = 0.08
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        shadowLayer.shadowRadius = 18.0
        shadowLayer.name = ShadowLayerNames.outerShadowLayer.rawValue
        
        layer.addSublayer(shadowLayer)
    }
}

//
//  StyledSlider.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/07/2022.
//

import UIKit

final class StyledSlider: UISlider {
//    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        var targetRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
//
//        let trackProgress = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
//        let centerX = (bounds.maxX - bounds.minX) * trackProgress
//        let minX = centerX - targetRect.width / 2.0
//
//        targetRect.origin.x = minX
//
//        return targetRect
//    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let minY = bounds.midY - 5.0
        let targetRect = CGRect(x: 0.0, y: minY, width: bounds.width, height: 10.0)
        
        return targetRect
    }
}

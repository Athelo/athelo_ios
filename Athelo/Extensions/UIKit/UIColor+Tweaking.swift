//
//  UIColor+Tweaking.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 14/06/2022.
//

import Foundation
import UIKit

extension UIColor {
    func adjustingHSBByPercentile(hueChange: Double = 0.0, saturationChange: Double = 0.0, brightnessChange: Double = 0.0) -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }
        
        let targetHue = max(0.0, min(1.0, hue + hueChange))
        let targetSaturation = max(0.0, min(1.0, saturation + saturationChange))
        let targetBrightness = max(0.0, min(1.0, brightness + brightnessChange))
        
        return UIColor(hue: targetHue, saturation: targetSaturation, brightness: targetBrightness, alpha: alpha)
    }
}

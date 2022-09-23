//
//  UIImage+Orientation.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import Foundation
import UIKit

extension UIImage {
    func withFixedOrientation() -> UIImage {
        switch imageOrientation {
        case .up:
            return self
        default:
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            draw(in: CGRect(origin: .zero, size: size))
            let result = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return result ?? self
        }
    }
}

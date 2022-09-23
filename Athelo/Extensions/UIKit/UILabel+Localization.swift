//
//  UILabel+Localization.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation
import UIKit

extension UILabel {
    @IBInspectable var localizedTitle: String? {
        get {
            text?.localized()
        }
        set {
            guard let value = newValue, value.localized() != value else {
                return
            }
            
            text = value.localized()
        }
    }
}

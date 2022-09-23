//
//  UIButton+Localization.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation
import UIKit

extension UIButton {
    @IBInspectable var localizedTitle: String? {
        get {
            title(for: .normal)?.localized()
        }
        set {
            guard let value = newValue, value.localized() != value else {
                return
            }
            
            setTitle(value.localized(), for: .normal)
        }
    }
}

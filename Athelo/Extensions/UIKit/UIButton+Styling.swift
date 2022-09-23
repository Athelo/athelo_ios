//
//  UIButton+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 02/06/2022.
//

import Foundation
import UIKit

extension UIButton {
    func underlineTitle(for state: UIButton.State = .normal) {
        guard let title = title(for: state),
              let font = titleLabel?.font else {
            return
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: font
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        setAttributedTitle(attributedTitle, for: state)
    }
}

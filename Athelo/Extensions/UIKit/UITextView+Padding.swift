//
//  UITextView+Padding.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import UIKit

extension UITextView {
    func removePadding() {
        textContainer.lineFragmentPadding = 0.0
        textContainerInset = .zero
    }
}

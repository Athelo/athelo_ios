//
//  KeyboardInfo.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

struct KeyboardInfo {
    let rect: CGRect
    let animationTime: TimeInterval?
    private let animationCurveValue: Int?

    var animationCurve: UIView.AnimationCurve? {
        guard let value = animationCurveValue else {
            return nil
        }

        return UIView.AnimationCurve(rawValue: value)
    }

    init?(userInfo: [AnyHashable: Any]) {
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return nil
        }

        self.rect = frame
        self.animationTime = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        self.animationCurveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
    }
}

//
//  Buttons.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 01/06/2022.
//

import Foundation
import UIKit

protocol ThemedButton: UIButton {
    var style: UIFont.AppStyle { get }
    
    func applyStyling()
}

extension ThemedButton {
    func applyStyling() {
        titleLabel?.font = .withStyle(style)
    }
}

final class BodyButton: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .body
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class DefaultButton: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class Headline20Button: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .headline20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class Headline24Button: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .headline24
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class Headline30Button: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .headline30
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class LinkButton: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .link
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class PickerButton: UIButton, ThemedButton {
    var style: UIFont.AppStyle {
        .button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

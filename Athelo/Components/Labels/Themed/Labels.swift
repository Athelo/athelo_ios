//
//  Labels.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

protocol ThemedLabel: UILabel {
    var style: UIFont.AppStyle { get }
    
    func applyStyling()
}

extension ThemedLabel {
    func applyStyling() {
        font = .withStyle(style)
    }
}

class BaseThemeLabel: UILabel {
    @IBInspectable var lineHeightMultiple: Double = 1.24
    
    override var text: String? {
        get {
            super.attributedText?.string ?? super.text
        }
        set {
            guard let text = newValue else {
                super.attributedText = nil
                super.text = nil
                
                return
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            paragraphStyle.alignment = textAlignment
            
            var attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle
            ]
            
            if lineHeightMultiple > 1.0 {
                attributes[.baselineOffset] = (abs(font.ascender - font.capHeight) / 2.0) * (lineHeightMultiple - 1.0)
            }
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            self.attributedText = attributedString
        }
    }
}

final class ArticleBodyLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .articleBody
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

final class ArticleHeadlineLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .articleHeadline
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

class BodyLabel: BaseThemeLabel, ThemedLabel {
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

final class ButtonLabel: BaseThemeLabel, ThemedLabel {
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

final class FormLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .form
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

final class Headline20Label: BaseThemeLabel, ThemedLabel {
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

final class Headline24Label: BaseThemeLabel, ThemedLabel {
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

final class Headline30Label: BaseThemeLabel, ThemedLabel {
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

final class IntroLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .intro
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

final class LinkLabel: BaseThemeLabel, ThemedLabel {
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

final class MessageInfoLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .messageInfo
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

final class MessageLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .message
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

final class ParagraphLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .paragraph
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

final class PillLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .pill
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

final class SubheadingLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .subheading
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

final class SubtitleLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .subtitle
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

final class TextFieldLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .textField
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

final class TextFieldErrorLabel: BaseThemeLabel, ThemedLabel {
    var style: UIFont.AppStyle {
        .textFieldError
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

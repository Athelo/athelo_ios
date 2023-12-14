//
//  TextViews.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 13/06/2022.
//

import Foundation
import UIKit

protocol ThemedTextView: UITextView {
    var style: UIFont.AppStyle { get }
    
    func applyStyling()
}

extension ThemedTextView {
    func applyStyling() {
        font = .withStyle(style)
    }
}

class BaseThemeTextView: UITextView {
    @IBInspectable var lineHeightMultiple: Double = 1.24
    
    override var text: String! {
        get {
            super.attributedText?.string ?? super.text
        }
        set {
            guard let text = newValue,
                  let font = font else {
                super.attributedText = nil
                super.text = nil
                
                return
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            paragraphStyle.alignment = textAlignment
            
            var attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: font
            ]
            
            if let textColor = textColor {
                attributes[.foregroundColor] = textColor
            }
            
            if lineHeightMultiple != 1.0 {
                attributes[.baselineOffset] = abs(font.ascender - font.capHeight) / 2.0
            }
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            self.attributedText = attributedString
        }
    }
}

final class BodyTextView: BaseThemeTextView, ThemedTextView {
    var style: UIFont.AppStyle {
        .body
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class FormContentTextView: BaseThemeTextView, ThemedTextView {
    var style: UIFont.AppStyle {
        .form
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class Headline20TextView: BaseThemeTextView, ThemedTextView {
    var style: UIFont.AppStyle {
        .headline20
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class ParagraphTextView: BaseThemeTextView, ThemedTextView {
    var style: UIFont.AppStyle {
        .paragraph
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

final class SubheadingTextView: BaseThemeTextView, ThemedTextView {
    var style: UIFont.AppStyle {
        .subheading
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyStyling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyling()
    }
}

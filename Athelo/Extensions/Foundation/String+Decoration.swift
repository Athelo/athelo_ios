//
//  String+Decoration.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 03/04/2023.
//

import Foundation
import UIKit

extension String {
    static func paragraph(lineHeightMultiple: Double = 1.24, alignment: NSTextAlignment = .center, lineBreakMode: NSLineBreakMode = .byTruncatingTail, lineBreakStrategy: NSParagraphStyle.LineBreakStrategy = .standard) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineBreakStrategy = lineBreakStrategy
        
        return paragraphStyle
    }
    
    private static var defaultParagraph: NSParagraphStyle = {
        paragraph()
    }()
    
    func marking(_ substring: String, withTraits traits: UIFontDescriptor.SymbolicTraits, sourceFont font: UIFont, paragraphStyle: NSParagraphStyle = String.defaultParagraph) -> NSAttributedString {
        let message = NSMutableAttributedString(string: self, attributes: [.paragraphStyle: paragraphStyle])
        
        let range = (message.string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return message
        }
        
        if let fontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            message.addAttributes([.font: UIFont(descriptor: fontDescriptor, size: font.pointSize)], range: range)
        }
        
        return message
    }
    
    func marking(_ substring: String, withFont font: UIFont, paragraphStyle: NSParagraphStyle = String.defaultParagraph) -> NSAttributedString {
        let message = NSMutableAttributedString(string: self, attributes: [.paragraphStyle: paragraphStyle])
        
        let range = (message.string as NSString).range(of: substring)
        guard range.location != NSNotFound else {
            return message
        }
        
        message.addAttributes([.font: font], range: range)
        
        return message
    }
}

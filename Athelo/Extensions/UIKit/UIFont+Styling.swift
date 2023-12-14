//
//  UIFont+Styling.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 30/05/2022.
//

import UIKit

extension UIFont {
    enum AppStyle {
        case articleBody
        case articleHeadline
        case body
        case boldHeadline20
        case boldHeadline24
        case button
        case emoji
        case form
        case headline20
        case headline24
        case headline30
        case intro
        case legend
        case link
        case message
        case messageInfo
        case paragraph
        case pill
        case slider
        case subheading
        case subtitle
        case textField
        case textFieldError
    }
    
    static func colorForStyle(_ style: AppStyle) -> UIColor {
        switch style {
        case .articleHeadline, .body, .button, .emoji, .form, .headline20, .headline24, .headline30, .link, .message, .textField:
            return .withStyle(.black)
        case .boldHeadline20, .boldHeadline24:
            return .withStyle(.lightOlivaceous)
        case .intro, .pill:
            return .withStyle(.purple623E61)
        case .messageInfo:
            return .withStyle(.white)
        case .articleBody, .legend, .paragraph, .slider, .subheading, .subtitle:
            return .withStyle(.gray)
        case .textFieldError:
            return .withStyle(.redFF0000)
        }
    }
    
    static func withStyle(_ style: AppStyle) -> UIFont {
        switch style {
        case .articleBody:
            return UIFont(name: "Inter-Regular", size: 12.0)!
        case .articleHeadline:
            return UIFont(name: "Inter-SemiBold", size: 15.0)!
        case .body:
            return UIFont(name: "Inter-Regular", size: 14.0)!
        case .boldHeadline20:
            return UIFont(name: "Inter-Bold", size: 20.0)!
        case .boldHeadline24:
            return UIFont(name: "Inter-Bold", size: 24.0)!
        case .button, .pill:
            return UIFont(name: "Inter-Medium", size: 16.0)!
        case .emoji:
            return UIFont(name: "Inter-Regular", size: 32.0)!
        case .form:
            return UIFont(name: "Inter-Regular", size: 16.0)!
        case .headline20:
            return UIFont(name: "Inter-Medium", size: 20.0)!
        case .headline24:
            return UIFont(name: "Inter-Medium", size: 24.0)!
        case .headline30:
            return UIFont(name: "Inter-Medium", size: 30.0)!
        case .intro:
            return UIFont(name: "Inter-Medium", size: 18.0)!
        case .legend:
            return UIFont(name: "Inter-SemiBold", size: 10.0)!
        case .link:
            return UIFont(name: "Inter-Regular", size: 15.0)!
        case .message:
            return UIFont(name: "Inter-Regular", size: 16.0)!
        case .messageInfo:
            return UIFont(name: "Inter-MediumItalic", size: 12.0)!
        case .paragraph:
            return UIFont(name: "Inter-Regular", size: 18.0)!
        case .slider:
            return UIFont(name: "Inter-Regular", size: 14.0)!
        case .subheading:
            return UIFont(name: "Inter-SemiBold", size: 16.0)!
        case .subtitle:
            return UIFont(name: "Inter-SemiBold", size: 12.0)!
        case .textField:
            return UIFont(name: "Inter-Regular", size: 16.0)!
        case .textFieldError:
            return UIFont(name: "Inter-Medium", size: 12.0)!
        }
    }
}

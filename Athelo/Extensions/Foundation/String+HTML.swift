//
//  String+HTML.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import Foundation
import UIKit

extension String {    
    func htmlDecorated(font: UIFont = .withStyle(.body)) -> String {
        let escaped = self
            .replacingOccurrences(of: #"[\t|\r]"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"(<ol>|<ul>|<\/li>)\n(<li>|<\/ol>|<\/ul>)"#, with: #"$1$2"#, options: .regularExpression)
            .replacingOccurrences(of: #"(\n){1,}"#, with: "<br/>", options: .regularExpression)
            .replacingOccurrences(of: #"(<br/>){0,1}(<ol>|<ul>)"#, with: "<br/><br/>$2", options: .regularExpression)
            .replacingOccurrences(of: "(</p>)(<br/>){0,1}(<p[>| ])", with: "$1<br/><br/>$3", options: .regularExpression)
            .replacingOccurrences(of: #"</a>(<br/>){1}"#, with: "<a><br/><br/>", options: .regularExpression)
        
        return """
            <html>
                <head>
                    <style type="text/css">
                        body, p {
                            color: #6D6D6D;
                            display: inline;
                            font-size: \(font.pointSize)px;
                            font-family: \(font.fontName);
                            margin: 0px;
                            padding: 0px;
                            text-align: left;
                        }

                        body, a {
                            display: inline;
                        }
        
                        body {
                            background-color: #00000000;
                        }
                    </style>
                </head>
                <body>\(escaped)</body>
            </html>
        """
    }
    
    func toAttributedHTML(font: UIFont = .withStyle(.body), textAlignment: NSTextAlignment = .natural) -> NSAttributedString {
        guard let data = htmlDecorated(font: font).data(using: .utf8),
              let htmlString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return NSAttributedString(string: self)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.24
        paragraphStyle.alignment = textAlignment

        htmlString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: htmlString.length))
        
        return htmlString
    }
}

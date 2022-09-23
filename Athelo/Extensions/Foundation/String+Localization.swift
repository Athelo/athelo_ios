//
//  String+Localization.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

extension String {
    func localized(comment: String? = nil, arguments: [CVarArg]? = nil) -> String {
        let localizedString = NSLocalizedString(self, comment: comment ?? "")
        let targetString = localizedString != self ? localizedString : self
        
        if let args = arguments {
            return String(format: targetString, locale: nil, args)
        }
        
        return targetString
    }
}

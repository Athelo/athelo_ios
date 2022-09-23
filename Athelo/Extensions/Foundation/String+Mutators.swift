//
//  String+Mutators.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 09/06/2022.
//

import Foundation

extension String {
    func extractingInitials(maxLength: Int = 2) -> String {
        let initials = self.split(separator: " ").compactMap({ $0.first }).map({ String($0) }).joined().uppercased()

        if maxLength > 0 {
            return String(initials.prefix(maxLength))
        }

        return initials
    }
}

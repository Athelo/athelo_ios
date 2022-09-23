//
//  File.swift
//  
//
//  Created by Krzysztof Jabłoński on 28/06/2022.
//

import Foundation

extension String {
    /// Strips any content after first colon.
    ///
    /// For example:
    /// * String "`random-uuid:APP-ID`" is going to be formatted to "`random-uuid`".
    /// * String "`random-uuid:additional-param:APP-ID`" is going to be formatted to "`random-uuid`".
    /// * String "`random-uuid;APP-ID`" will be left untouched.
    ///
    /// - Returns: Stripped string.
    func sansApplicationCodeSuffix() -> String {
        if let suffixRange = range(of: ":.*", options: .regularExpression) {
            var trimmedString = self
            trimmedString.replaceSubrange(suffixRange, with: "")

            return trimmedString.trimmingCharacters(in: .whitespaces)
        } else {
            return self
        }
    }
}

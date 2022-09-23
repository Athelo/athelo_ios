//
//  Bundle+DictionaryKeys.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 06/06/2022.
//

import Foundation

extension Bundle {
    var appBuild: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}

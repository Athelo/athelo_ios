//
//  AccessCodeUtility.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 22/02/2023.
//

import Foundation

final class AccessCodeUtility {
    static var codeHasBeenProvided: Bool {
        UserDefaultsKey.value(for: .keyEntered) == true
    }
    
    static func checkCode(_ code: String) -> Bool {
        guard code == Constants.accessCode else {
            return false
        }
        
        UserDefaultsKey.setValue(true, for: .keyEntered)
        
        return true
    }
}

// MARK: - Helper extensions
private extension AccessCodeUtility {
    enum Constants {
        static let accessCode: String = "1107"
    }
    
    enum UserDefaultsKey {
        case keyEntered
        
        private var key: String {
            switch self {
            case .keyEntered:
                return "athelo.accesscode.entered"
            }
        }
        
        static func resetValue(for key: UserDefaultsKey) {
            UserDefaults.standard.set(nil, forKey: key.key)
        }
        
        static func setValue<T>(_ value: T, for key: UserDefaultsKey) {
            UserDefaults.standard.set(value, forKey: key.key)
        }
        
        static func value<T>(for key: UserDefaultsKey) -> T? {
            UserDefaults.standard.value(forKey: key.key) as? T
        }
    }
}

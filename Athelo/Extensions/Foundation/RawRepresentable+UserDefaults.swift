//
//  RawRepresentable+UserDefaults.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/03/2023.
//

import Foundation

protocol UserDefaultsBridge {
    var key: String { get }
    var store: UserDefaults { get }
    
    func setValue<Value>(_ value: Value)
    func resetValue()
    func value<Value>() -> Value?
}

extension UserDefaultsBridge {
    func setValue<Value>(_ value: Value) {
        store.set(value, forKey: key)
    }
    
    func resetValue() {
        store.set(nil, forKey: key)
    }
    
    func value<Value>() -> Value? {
        store.value(forKey: key) as? Value
    }
}

extension RawRepresentable where Self: UserDefaultsBridge, RawValue == String {
    var key: String {
        rawValue
    }
    
    var store: UserDefaults {
        .standard
    }
    
    static func setValue<Value>(_ value: Value, for key: Self) {
        key.setValue(value)
    }
    
    static func resetValue(for key: Self) {
        key.resetValue()
    }
    
    static func value<Value>(for key: Self) -> Value? {
        key.value()
    }
}

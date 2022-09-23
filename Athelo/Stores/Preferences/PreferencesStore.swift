//
//  Preferences.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 31/05/2022.
//

import Foundation

final class PreferencesStore {
    // MARK: - Constants
    fileprivate enum Key: String {
        case communitiesLandingDisplayed = "communities.landing.displayed"
        case introDisplayed = "intro.displayed"
        
        var key: String {
            "athelo.\(rawValue)"
        }
    }
    
    // MARK: - Properties
    private static var store = UserDefaults.standard
    
    // MARK: - Public API
    static func hasDisplayedCommunitiesLanding() -> Bool {
        store.value(forKey: .communitiesLandingDisplayed) ?? false
    }
    
    static func hasDisplayedIntro() -> Bool {
        store.value(forKey: .introDisplayed) ?? false
    }
    
    static func setCommunitiesLandingAsDisplayed(_ displayed: Bool) {
        store.set(displayed, forKey: .communitiesLandingDisplayed)
    }
    
    static func setIntroAsDisplayed() {
        store.set(true, forKey: .introDisplayed)
    }
}

private extension UserDefaults {
    func value<T>(forKey key: PreferencesStore.Key) -> T? {
        object(forKey: key.key) as? T
    }
    
    func set<T>(_ value: T?, forKey key: PreferencesStore.Key) {
        set(value, forKey: key.key)
    }
}

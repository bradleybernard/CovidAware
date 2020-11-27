//
//  UserDefaults+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/24/20.
//

import Foundation

extension UserDefaults {
    private enum Keys: String {
        case favoriteStates
    }

    // String value for USAState.rawValue since Enums can't be represented in Obj-C
    @objc var favoriteStates: [String] {
        get {
            array(forKey: Keys.favoriteStates.rawValue) as? [String] ?? []
        }
        set {
            set(newValue, forKey: Keys.favoriteStates.rawValue)
        }
    }
}

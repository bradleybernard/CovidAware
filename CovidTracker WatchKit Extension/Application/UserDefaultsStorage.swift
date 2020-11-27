//
//  UserDefaultsStorage.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/24/20.
//

import Foundation

class UserDefaultsStorage: ObservableObject {
    @Published var favoriteStates: [USAState] {
        willSet(newValue) {
            if newValue != favoriteStates {
                UserDefaults.standard.favoriteStates = Self.statesToStrings(USAStates: newValue)
            }
        }
    }

    init() {
        favoriteStates = Self.stringsToStates(strings: UserDefaults.standard.favoriteStates)
    }

    private static func statesToStrings(USAStates: [USAState]) -> [String] {
        USAStates.map(\.rawValue)
    }

    private static func stringsToStates(strings: [String]) -> [USAState] {
        strings.compactMap { string in
            USAState(rawValue: string)
        }
    }
}

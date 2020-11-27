//
//  ViewState.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

enum ViewState: String, Equatable, CaseIterable {
    case initialLoad
    case subsequentLoad
    case newContentAvailable
    case content
    case empty
    case error

    var shouldShowSubsequentLoader: Bool {
        self == .subsequentLoad || self == .newContentAvailable
    }
}

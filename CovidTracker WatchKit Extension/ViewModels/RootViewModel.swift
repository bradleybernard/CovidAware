//
//  RootViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import SwiftUI

class RootViewModel: ObservableObject {
    enum Tab: Int, Equatable, CaseIterable {
        case usToday
        case usStates
        case about
    }

    private static let initialTab: Tab = .usToday

    @Published var selectedTab: Tab = RootViewModel.initialTab {
        didSet {
            if selectedTabId != selectedTab.rawValue {
                selectedTabId = selectedTab.rawValue
            }
        }
    }

    @Published var selectedTabId: Int = RootViewModel.initialTab.rawValue {
        didSet {
            if let tab = Tab(rawValue: selectedTabId), selectedTab != tab {
                selectedTab = tab
            }
        }
    }

    func tappedStates() {
        selectedTab = .usStates
    }
}

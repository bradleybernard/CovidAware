//
//  RootView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import SwiftUI

struct RootView: View {
    @StateObject var viewModel: RootViewModel

    @StateObject var userDefaultsStorage = UserDefaultsStorage()
    @EnvironmentObject var notificationsManager: NotificationsManager

    var body: some View {
        NavigationView {
            TabView(selection: $viewModel.selectedTabId) {
                USTodayView(viewModel: USTodayViewModel(tappedStates: viewModel.tappedStates))
                    .tag(RootViewModel.Tab.usToday.rawValue)

                StatesView()
                    .tag(RootViewModel.Tab.usStates.rawValue)

                AboutView()
                    .tag(RootViewModel.Tab.about.rawValue)
            }
        }
        .environmentObject(userDefaultsStorage)
    }
}

#if DEBUG
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .init(notificationsManager: NotificationsManager()))
    }
}
#endif

//
//  CovidTrackerApp.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/23/20.
//

import SwiftUI
import WatchKit

@main
struct CovidTrackerApp: App {
    //swiftlint:disable weak_delegate
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(delegate.lifecycleManager)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

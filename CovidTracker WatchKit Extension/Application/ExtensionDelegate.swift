//
//  ExtensionDelegate.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/28/20.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let lifecycleManager = LifecycleManager()

    private lazy var backgroundTaskProcessor: BackgroundTaskProcessor = {
        let taskProcessor = BackgroundTaskProcessor()
        taskProcessor.scheduleBackgroundRefresh = { [weak lifecycleManager] in
            lifecycleManager?.scheduleBackgroundRefresh()
        }

        return taskProcessor
    }()

    func applicationDidFinishLaunching() {
        lifecycleManager.applicationDidFinishLaunching()
    }

    func applicationDidBecomeActive() {
    }

    func applicationWillResignActive() {
    }

    func applicationWillEnterForeground() {
    }

    func applicationDidEnterBackground() {
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        backgroundTaskProcessor.handle(backgroundTasks)
    }
}

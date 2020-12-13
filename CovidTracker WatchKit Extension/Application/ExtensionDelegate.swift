//
//  ExtensionDelegate.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/28/20.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    let lifecycleManager = LifecycleManager()
    let notificationsManager = NotificationsManager()

    private lazy var backgroundTaskProcessor: BackgroundTaskProcessor = {
        let taskProcessor = BackgroundTaskProcessor()

        taskProcessor.scheduleBackgroundRefresh = { [weak lifecycleManager] in
            lifecycleManager?.scheduleBackgroundRefresh()
        }

        taskProcessor.scheduleLocalNotification = { [weak notificationsManager] in
            notificationsManager?.scheduleLocalNotification()
        }

        return taskProcessor
    }()

    func applicationDidFinishLaunching() {
        lifecycleManager.applicationDidFinishLaunching()
        notificationsManager.requestNotificationsAuthorizationIfNeeded()
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

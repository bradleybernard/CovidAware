//
//  BackgroundTaskProcessor.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/2/20.
//

import WatchKit
import os

// NSObject required since URLSessionDelegate inherits from NSObjectProtocol
class BackgroundTaskProcessor: NSObject {
/*
https://developer.apple.com/documentation/watchkit/wkapplicationrefreshbackgroundtask
Background app refresh tasks are budgeted. In general, the system performs approximately
one task per hour for each app in the dock (including the most recently used app). This budget
is shared among all apps on the dock. The system performs multiple tasks an hour for each app
with a complication on the active watch face. This budget is shared among all complications
on the watch face. After you exhaust the budget, the system delays your requests until more time
becomes available.
*/
    var scheduleBackgroundRefresh: (() -> Void)?
    var scheduleLocalNotification: (() -> Void)?

    private lazy var backgroundURLSession = {
        DataService.makeBackgroundURLSession(delegate: self)
    }()

    private var urlSessionTasks: [WKURLSessionRefreshBackgroundTask] = []

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            os_log("Handling background task: \(task)")

            switch task {
                case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                    snapshotTask.setTaskCompletedWithSnapshot(false)
                case let refreshTask as WKApplicationRefreshBackgroundTask:
                    handleRefreshTask(refreshTask)
                case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                    handleURLSessionTask(urlSessionTask)
                default:
                    task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func handleRefreshTask(_ refreshBackgroundTask: WKApplicationRefreshBackgroundTask) {
        scheduleBackgroundRefresh?()

        ViewModelManager.shared.triggerBackgroundRefresh(urlSession: backgroundURLSession) {
            refreshBackgroundTask.setTaskCompletedWithSnapshot(false)
        }
    }

    func handleURLSessionTask(_ urlSessionTask: WKURLSessionRefreshBackgroundTask) {
        os_log("handleURLSessionTask(_ urlSessionTask: WKURLSessionRefreshBackgroundTask): \(urlSessionTask.sessionIdentifier)")
        urlSessionTasks.append(urlSessionTask)

        // Create dummy url session to connect to background session to fire delegate methods
        let configuration = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
        _ = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
}

extension BackgroundTaskProcessor: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location) else {
            return
        }

        os_log("urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL): \(location)")
        ViewModelManager.shared.downloadTaskCompleted(downloadTask, with: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else {
            return
        }

        os_log("urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?): \(error.localizedDescription)")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        os_log("urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession): \(session)")

        urlSessionTasks.forEach { urlSessionTask in
            urlSessionTask.setTaskCompletedWithSnapshot(false)
        }

        urlSessionTasks.removeAll()

        scheduleLocalNotification?()
    }
}

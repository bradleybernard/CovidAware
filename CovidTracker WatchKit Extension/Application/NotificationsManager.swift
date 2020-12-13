//
//  NotificationsManager.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 12/13/20.
//

import Foundation
import UserNotifications
import os

class NotificationsManager: NSObject, ObservableObject {
    @Published var isAuthorized = false

    var selectTab: ((RootViewModel.Tab) -> Void)?
    private let notificationCenter = UNUserNotificationCenter.current()

    enum Category: String {
        case dataUpdated = "DATA_UPDATED"
    }

    enum Action: String, CaseIterable {
        case unitedStates = "UNITED_STATES"
        case states = "STATES"

        var title: String {
            switch self {
                case .unitedStates:
                    return "United States"
                case .states:
                    return "States"
            }
        }
    }

    init(selectTab: ((RootViewModel.Tab) -> Void)? = nil) {
        super.init()

        self.selectTab = selectTab
        notificationCenter.delegate = self

        configureNotifications()
        getNotificationPermissions()
    }

    private func configureNotifications() {
        // Define the custom actions.
        let actions = Action.allCases.map { action in
            UNNotificationAction(identifier: action.rawValue, title: action.title, options: [.foreground])
        }

        // Define the notification type
        let dataUpdatedCategory = UNNotificationCategory(identifier: Category.dataUpdated.rawValue, actions: actions, intentIdentifiers: [])

        // Register the notification type.
        notificationCenter.setNotificationCategories([dataUpdatedCategory])
    }

    func scheduleLocalNotification() {
        getNotificationPermissions { [weak self] authorized in
            guard authorized else {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Check out today's new metrics!"
            content.categoryIdentifier = Category.dataUpdated.rawValue

            // Vibrate / make noise by default on WatchOS
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

            self?.notificationCenter.add(request) { error in
                if let error = error {
                    os_log("Failed to add notification to notification center. Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func getNotificationPermissions(completion: ((Bool) -> Void)? = nil) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            let authorized =
                settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional

            self?.isAuthorized = authorized

            completion?(authorized)
        }
    }

    func requestNotificationsAuthorizationIfNeeded() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            guard error == nil else {
                return
            }

            self?.isAuthorized = granted
        }
    }
}

extension NotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            switch response.actionIdentifier {
                case Action.unitedStates.rawValue:
                    self?.selectTab?(.usToday)
                case Action.states.rawValue:
                    self?.selectTab?(.usStates)
                default:
                    os_log("Error: unhandled notification response actionIdentifier: \(response.actionIdentifier)")
            }

            completionHandler()
        }
    }
}

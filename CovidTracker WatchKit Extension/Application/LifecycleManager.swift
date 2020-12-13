//
//  LifecycleManager.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/28/20.
//

import Foundation
import WatchKit
import os

class LifecycleManager: ObservableObject {
    @Published var scheduledBackgroundRefreshDate: Date?

    func applicationDidFinishLaunching() {
        scheduleBackgroundRefresh()
    }

    func scheduleBackgroundRefresh() {
        guard let easternTimeZone = TimeZone(abbreviation: "EST") else {
            fatalError("Could not create eastern timezone")
        }

        let calendar = Calendar.current
        let localTimeZone = calendar.timeZone

        os_log("Local timezone: \(localTimeZone)")

        let now = Date()

        // 7:00 PM EST via https://covidtracking.com/about-data
        let targetComponents = DateComponents(timeZone: easternTimeZone, hour: 19, minute: 0, second: 0)

        guard let easternTimeDate = calendar.nextDate(
            after: now,
            matching: targetComponents,
            matchingPolicy: .nextTime
        ) else {
            fatalError("Could not find the next scheduled update time")
        }

        let formatter = CommonDateFormatters.ISO6801
        formatter.timeZone = easternTimeZone

        os_log("(Current TZ) easternTimeDate: \(formatter.string(from: easternTimeDate))")

        guard var preferredFetchDate = calendar.dateBySetting(timeZone: localTimeZone, of: easternTimeDate) else {
            fatalError("Could not convert date to local timezone")
        }

        formatter.timeZone = localTimeZone
        os_log("(Target TZ) preferredFetchDate: \(formatter.string(from: easternTimeDate))")

        // If it is less than 5 minutes, then add one hour so OS doesn't get mad we scheduled a task too soon
        if preferredFetchDate.timeIntervalSince(now) < 5 * 60 {
            os_log("Time interval to now is too soon, adding one hour")
            preferredFetchDate.addTimeInterval(60 * 60)
        }

        scheduledBackgroundRefreshDate = preferredFetchDate

        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: preferredFetchDate, userInfo: nil) { error in
            os_log("Background task scheduled for preferred date: \(formatter.string(from: preferredFetchDate))")

            if let error = error {
                os_log("Background task error: \(error.localizedDescription) for preferred date: \(formatter.string(from: preferredFetchDate))")
            }
        }
    }
}

#if DEBUG
extension LifecycleManager {
    private func resetUserDefaults() {
        // Remove user defaults
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value) \n")
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
#endif

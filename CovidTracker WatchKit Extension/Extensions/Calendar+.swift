//
//  Calendar+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/18/20.
//

import Foundation

extension Calendar {
    func dateBySetting(timeZone: TimeZone, of date: Date) -> Date? {
        var components = dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        components.timeZone = timeZone
        return self.date(from: components)
    }
}

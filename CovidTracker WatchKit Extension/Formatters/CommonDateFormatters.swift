//
//  CommonDateFormatters.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/25/20.
//

import Foundation

enum CommonDateFormatters {
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    static let monthDayYearTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM d, YYYY h:mm a")
        return formatter
    }()

    static let monthDayYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMM d, YYYY")
        return formatter
    }()

    static let shortMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }()

    static let APIDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        return formatter
    }()

    static let ISO6801: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}

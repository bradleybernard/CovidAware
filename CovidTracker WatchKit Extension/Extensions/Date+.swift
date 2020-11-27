//
//  Date+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/22/20.
//

import Foundation
import os

extension Date {
    var tomorrow: Self {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: self) else {
            fatalError("Could not create tomorow date")
        }

        return tomorrow
    }

    var startOfMonth: Self {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        guard let startOfMonth = Calendar.current.date(from: components) else {
            fatalError("Could not create start of month date")
        }

        return startOfMonth
    }


    var endOfMonth: Date {
        let components = DateComponents(month: 1, second: -1)
        guard let endOfMonth = Calendar.current.date(byAdding: components, to: startOfMonth) else {
            fatalError("Could not create end of month date")
        }

        return endOfMonth
    }

    var nextMonth: Self {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self) else {
            fatalError("Could not create next month date")
        }

        return nextMonth
    }

    public var withoutTime: Self {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let dateWithoutTime = Calendar.current.date(from: components) else {
            fatalError("Could not get year month day from current date")
        }

        return dateWithoutTime
    }

    func days(from date: Date) -> Int {
        let dateComponents = Calendar.current.dateComponents([.day, .hour], from: date, to: self)
        let days = dateComponents.day ?? 0
        let hours = dateComponents.hour ?? 0

        if hours > 0 {
            return days + 1
        }

        return days
    }

    func months(from date: Date) -> Int {
        let dateComponents = Calendar.current.dateComponents([.month, .day], from: date, to: self)
        let days = dateComponents.day ?? 0
        let months = dateComponents.month ?? 0

        if days > 0 {
            return months + 1
        }

        return months
    }
}

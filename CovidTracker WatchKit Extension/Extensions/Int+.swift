//
//  Int+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import Foundation

extension Int {
    var abbreviatedString: String {
        if self >= 1000 && self < 10000 {
            return String(format: "%.1fK", Double(self / 100) / 10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000 && self < 1000000 {
            return "\(self / 1000)K"
        }

        if self >= 1000000 && self < 10000000 {
            return String(format: "%.1fM", Double(self / 100000) / 10).replacingOccurrences(of: ".0", with: "")
        }

        if self >= 10000000 {
            return "\(self / 1000000)M"
        }

        return String(self)
    }
}

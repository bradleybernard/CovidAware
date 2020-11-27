//
//  CommonNumberFormatters.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/25/20.
//

import Foundation

enum CommonNumberFormatters {
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minusSign = ""
        return formatter
    }()
}

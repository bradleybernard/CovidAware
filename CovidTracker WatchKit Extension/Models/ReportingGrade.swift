//
//  ReportingGrade.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/27/20.
//

import Foundation

// swiftlint:disable identifier_name

enum ReportingGrade: String, CaseIterable, Codable {
    case aPlus = "A+"
    case a = "A"
    case aMinus = "A-"
    case bPlus = "B+"
    case b = "B"
    case bMinus = "B-"
    case cPlus = "C+"
    case c = "C"
    case cMinus = "C-"
    case dPlus = "D+"
    case d = "D"
    case dMinus = "D-"
    case f = "F"
}

#if DEBUG
extension ReportingGrade {
    static let mock: Self = .bPlus
}
#endif

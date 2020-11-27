//
//  Double+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/11/20.
//

import Foundation

extension Double {
    var abbreviatedString: String {
        Int(self).abbreviatedString
    }
}

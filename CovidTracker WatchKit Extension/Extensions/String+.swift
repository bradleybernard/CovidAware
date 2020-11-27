//
//  String+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/17/20.
//

import Foundation

extension String {
    static func makeIdentifier(name: String) -> String {
        IdentifierUtilities.makeIdentifier(name: name)
    }
}

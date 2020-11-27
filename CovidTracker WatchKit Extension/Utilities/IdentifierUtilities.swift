//
//  IdentifierUtilities.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/17/20.
//

import Foundation

enum IdentifierUtilities {
    private static let prefix = "com.bradleybernard.CovidTracker.watchkitapp"

    static func makeIdentifier(name: String) -> String {
        "\(prefix).\(name)"
    }
}

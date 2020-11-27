//
//  CGPoint+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/26/20.
//

import Foundation
import CoreGraphics

// So we can use it in ForEach SwiftUI construct that requies Hashable conformance
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

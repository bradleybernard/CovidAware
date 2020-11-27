//
//  Sequence+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/27/20.
//

import Foundation

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { left, right in
            return left[keyPath: keyPath] < right[keyPath: keyPath]
        }
    }
}

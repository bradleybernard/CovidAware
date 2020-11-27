//
//  LazyView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/20/20.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

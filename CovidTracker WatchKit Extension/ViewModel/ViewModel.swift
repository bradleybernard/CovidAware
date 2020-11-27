//
//  ViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/16/20.
//

import Combine

class ViewModel: ObservableObject {
    @Published var viewState: ViewState

    init() {
        viewState = .initialLoad
    }
}

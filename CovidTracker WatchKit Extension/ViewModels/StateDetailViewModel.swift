//
//  StateDetailViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import SwiftUI

class StateDetailViewModel: RefreshableViewModel {
    @Published var covidHistorical: CovidHistoricalMetrics<CovidState>?
    @Published var covidState: CovidState? {
        // Bug that Binding<CovidProvider> does not emit an objectWillChange event
        willSet {
            objectWillChange.send()
        }
    }

    override var identifier: String {
        "StateDetail"
    }

    let USAState: USAState

    init(USAState: USAState) {
        self.USAState = USAState

        super.init()

        $covidHistorical
            .sink { [weak self] covidHistorical in
                self?.covidState = covidHistorical?.historical.first
            }
            .store(in: &cancellables)
    }

    override func fetchData(origin: FetchOrigin) {
        switch origin {
            case .backgroundTask(let backgroundURLSession):
                DataService.backgroundFetchHistoricalState(for: USAState, backgroundURLSession: backgroundURLSession)
            case .inApp:
                DataService.fetchHistoricalState(for: USAState)?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: receiveCompletion(completion:), receiveValue: handleData(covidStates:))
                    .store(in: &cancellables)
        }
    }

    override func handleBackgroundData(data: Data) {
        guard let covidStates = DataService.decodeHistoricalState(data: data) else {
            return
        }

        handleData(covidStates: covidStates)
    }

    func handleData(covidStates: [CovidState]) {
        defer {
            lastFetchedDate = Date()
            viewState = covidStates.isEmpty ? .empty : .content
        }

        guard let covidState = covidStates.first else {
            return
        }

        self.covidState = covidState
        covidHistorical = CovidHistoricalMetrics(entity: covidState, historical: covidStates)
    }
}

//
//  USTodayViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import Foundation
import os

class USTodayViewModel: RefreshableViewModel {
    @Published var covidCountryHistorical: CovidHistoricalMetrics<CovidCountry>?
    @Published var covidCountry: CovidCountry? {
        // Bug that Binding<CovidProvider> does not emit an objectWillChange event
        willSet {
            objectWillChange.send()
        }
    }

    override var identifier: String {
        "USToday"
    }

    let tappedStates: (() -> Void)

    init(tappedStates: @escaping () -> Void) {
        self.tappedStates = tappedStates
    }

    override func fetchData(origin: FetchOrigin) {
        switch origin {
            case .backgroundTask(let backgroundURLSession):
                DataService.backgroundFetchDailyUS(backgroundURLSession: backgroundURLSession)
            case .inApp:
                DataService.fetchDailyUS()?
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: receiveCompletion(completion:), receiveValue: handleData(countries:))
                    .store(in: &cancellables)
        }
    }

    override func handleBackgroundData(data: Data) {
        guard let countries = DataService.decodeDailyUS(data: data) else {
            return
        }

        handleData(countries: countries)
    }

    func handleData(countries: [CovidCountry]) {
        defer {
            lastFetchedDate = Date()
            viewState = countries.isEmpty ? .empty : .content
        }

        os_log("USTodayViewModel handled data")

        guard let covidCountry = countries.first else {
            return
        }

        self.covidCountry = covidCountry
        covidCountryHistorical = CovidHistoricalMetrics(entity: covidCountry, historical: countries)
    }
}

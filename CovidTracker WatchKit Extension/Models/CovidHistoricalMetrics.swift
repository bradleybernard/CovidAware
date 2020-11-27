//
//  CovidHistoricalMetrics.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/12/20.
//

import Foundation

struct CovidHistoricalMetrics<MetricProvider: CovidMetricProvider>: Identifiable {
    let entity: MetricProvider
    let historical: [MetricProvider]

    var id: String {
        entity.hash
    }
}

#if DEBUG
extension CovidHistoricalMetrics where MetricProvider == CovidState {
    static let mock = CovidHistoricalMetrics<MetricProvider>(entity: .mock, historical: [.mock])
}

extension CovidHistoricalMetrics where MetricProvider == CovidCountry {
    static let mock = CovidHistoricalMetrics<MetricProvider>(entity: .mock, historical: [.mock])
}

extension Array where Element == CovidState {
    static var mock: Self {
        [.mock]
    }
}

extension Array where Element == CovidCountry {
    static var mock: Self {
        [.mock]
    }
}
#endif

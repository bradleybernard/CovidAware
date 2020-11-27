//
//  CovidCountry.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/23/20.
//

import Foundation

struct CovidCountry: Codable, Identifiable, Equatable, Hashable {
    let positive: Int?
    let positiveIncrease: Int?

    let negative: Int?
    let negativeIncrease: Int?

    let death: Int?
    let deathIncrease: Int?

    let recovered: Int?

    let totalTestResults: Int?
    let totalTestResultsIncrease: Int?

    let hospitalized: Int?
    let hospitalizedIncrease: Int?

    let hospitalizedCurrently: Int?
    let hospitalizedCumulative: Int?

    let positiveCasesViral: Int?
    let probableCases: Int?

    let totalTestsAntibody: Int?

    let inIcuCurrently: Int?
    let inIcuCumulative: Int?

    let onVentilatorCurrently: Int?
    let onVentilatorCumulative: Int?

    let deathProbable: Int?
    let deathConfirmed: Int?

    let totalTestsPeopleViral: Int?
    let totalTestsViral: Int?
    let totalTestEncountersViral: Int?

    let date: Date
    let dateChecked: Date?
    let hash: String

    var id: String {
        hash
    }
}

// MARK: - CovidMetricProvider

extension CovidCountry: CovidMetricProvider {}

#if DEBUG
extension CovidCountry {
    static let mock = CovidCountry(
        positive: 1,
        positiveIncrease: 1,
        negative: 1,
        negativeIncrease: 1,
        death: 1,
        deathIncrease: 1,
        recovered: 1,
        totalTestResults: 1,
        totalTestResultsIncrease: 1,
        hospitalized: 1,
        hospitalizedIncrease: 1,
        hospitalizedCurrently: 1,
        hospitalizedCumulative: 1,
        positiveCasesViral: 1,
        probableCases: 1,
        totalTestsAntibody: 1,
        inIcuCurrently: 1,
        inIcuCumulative: 1,
        onVentilatorCurrently: 1,
        onVentilatorCumulative: 1,
        deathProbable: 1,
        deathConfirmed: 1,
        totalTestsPeopleViral: 1,
        totalTestsViral: 1,
        totalTestEncountersViral: 1,
        date: Date(),
        dateChecked: Date(),
        hash: "12345"
    )
}
#endif

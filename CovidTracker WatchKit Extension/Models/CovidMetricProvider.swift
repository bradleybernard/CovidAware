//
//  CovidMetricProvider.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/12/20.
//

import Foundation

protocol CovidMetricProvider {
    var death: Int? { get }
    var deathIncrease: Int? { get }
    var deathProbable: Int? { get }
    var deathConfirmed: Int? { get }

    var positive: Int? { get }
    var positiveIncrease: Int? { get }
    var positiveCasesViral: Int? { get }
    var probableCases: Int? { get }

    var negative: Int? { get }
    var negativeIncrease: Int? { get }

    var recovered: Int? { get }

    var hospitalized: Int? { get }
    var hospitalizedIncrease: Int? { get }

    var hospitalizedCurrently: Int? { get }
    var hospitalizedCumulative: Int? { get }

    var totalTestEncountersViral: Int? { get }
    var totalTestsViral: Int? { get }
    var totalTestsAntibody: Int? { get }
    var totalTestsPeopleViral: Int? { get }
    var totalTestResults: Int? { get }
    var totalTestResultsIncrease: Int? { get }

    var inIcuCurrently: Int? { get }
    var inIcuCumulative: Int? { get }

    var onVentilatorCurrently: Int? { get }
    var onVentilatorCumulative: Int? { get }

    var date: Date { get }
    var hash: String { get }
}

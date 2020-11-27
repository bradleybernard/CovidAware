//
//  MetricType.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/26/20.
//

import Foundation
import SwiftUI

enum MetricType: String, CaseIterable, Identifiable {
    // Positive
    case totalCases = "Total cases"
    case confirmedCases = "Confirmed cases"
    case probableCases = "Probable cases"
    case newCasesToday = "Daily new cases"

    // Viral (PCR) Tests
    case totalTestEncounters = "Total tests (encounters)"
    case totalTestSpecimen = "Total tests (specimen)"
    case totalTestPeople = "Total tests (people)"

    // Antibody tests
    case totalTests = "Total tests"

    // Hospitalization
    case everHospitalized = "Ever hospitalized"
    case nowHopsitalized = "Now hospitalized"
    case everInICU = "Ever in ICU"
    case nowInICU = "Now in ICU"
    case everOnVentilator = "Ever on ventilator"
    case nowOnVentilator = "Now on ventilator"

    // Outcomes
    case recovered = "Recovered"
    case totalDeaths = "Total deaths"
    case probableDeaths = "Probable deaths"
    case confirmedDeaths = "Confirmed deaths"
    case deathIncrease = "Daily deaths"

    var id: String {
        rawValue
    }

    var valueKeyPath: KeyPath<CovidMetricProvider, Int?> {
        switch self {
            case .totalCases:
                return \.positive
            case .confirmedCases:
                return \.positiveCasesViral
            case .probableCases:
                return \.probableCases
            case .newCasesToday:
                return \.positiveIncrease
            case .totalTestEncounters:
                return \.totalTestEncountersViral
            case .totalTestSpecimen:
                return \.totalTestsViral
            case .totalTestPeople:
                return \.totalTestsPeopleViral
            case .totalTests:
                return \.totalTestsAntibody
            case .everHospitalized:
                return \.hospitalizedCumulative
            case .nowHopsitalized:
                return \.hospitalizedCurrently
            case .everInICU:
                return \.inIcuCumulative
            case .nowInICU:
                return \.inIcuCurrently
            case .everOnVentilator:
                return \.onVentilatorCumulative
            case .nowOnVentilator:
                return \.onVentilatorCurrently
            case .recovered:
                return \.recovered
            case .totalDeaths:
                return \.death
            case .probableDeaths:
                return \.deathProbable
            case .confirmedDeaths:
                return \.deathConfirmed
            case .deathIncrease:
                return \.deathIncrease
        }
    }

    var increaseColor: Color? {
        switch self {
            case .totalCases, .confirmedCases, .probableCases, .newCasesToday, .everHospitalized, .nowHopsitalized, .everInICU, .nowInICU, .everOnVentilator, .nowOnVentilator, .totalDeaths, .probableDeaths, .confirmedDeaths, .deathIncrease:
                return .red
            case .recovered:
                return .green
            case .totalTestEncounters, .totalTestSpecimen, .totalTestPeople, .totalTests:
                return nil
        }
    }

    var decreaseColor: Color? {
        switch self {
            case .totalCases, .confirmedCases, .probableCases, .newCasesToday, .everHospitalized, .nowHopsitalized, .everInICU, .nowInICU, .everOnVentilator, .nowOnVentilator, .totalDeaths, .probableDeaths, .confirmedDeaths, .deathIncrease:
                return .green
            case .recovered:
                return .red
            case .totalTestEncounters, .totalTestSpecimen, .totalTestPeople, .totalTests:
                return nil
        }
    }

    // swiftlint:disable line_length
    var definition: String {
        switch self {
            case .totalCases, .confirmedCases:
                return "Total number of confirmed plus probable cases of COVID-19 reported by the state or territory, ideally per the August 5, 2020 CSTE case definition. Some states are following the older April 5th, 2020 CSTE case definition or using their own custom definitions. Not all states and territories report probable cases. If a state is not reporting probable cases, this field will just represent confirmed cases."
            case .probableCases:
                return "Total number of probable cases of COVID-19 as reported by the state or territory, ideally per the August 5, 2020 CSTE case definition. By this definition, a probable case is someone who tests positive via antigen without a positive PCR or other approved nucleic acid amplification test (NAAT), someone with clinical and epidemiological evidence of COVID-19 infection with no confirmatory laboratory testing performed for SARS-CoV-2, or someone with COVID-19 listed on their death certificate with no confirmatory laboratory testing performed for SARS-CoV-2. Some states are following the older April 5th, 2020 CSTE case definition or using their own custom definitions."
            case .newCasesToday:
                return "The daily increase in API field positive, which measures Cases (confirmed plus probable) calculated based on the previous day’s value."
            case .totalTestEncounters:
                return "Total number of people tested per day via PCR testing as reported by the state or territory. The count for this metric is incremented up by one for each day on which an individual person is tested, no matter how many specimens are collected from that person on that day. If an individual person is tested twice a day on three different days, this count will increment up by three. If we discover that a jurisdiction is including antigen tests in this metric, we will annotate that state or territory’s data accordingly."
            case .totalTestSpecimen:
                return "Total number of PCR tests (or specimens tested) as reported by the state or territory. The count for this metric is incremented up each time a specimen is tested and the result is reported. If we discover that a jurisdiction is including antigen tests in this metric, we will annotate that state or territory’s data accordingly. For states with ambiguous annotations, we have assigned their total tests to this category; these states and territories are identified in the new API field covidTrackingProjectPreferredTotalTestUnits as having “Unclear units.”"
            case .totalTestPeople:
                return
                    """
                    Total number of unique people tested at least once via PCR testing, as reported by the state or territory. The count for this metric is incremented up only the first time an individual person is tested and their result is reported. Future tests of the same person will not be added to this count. In the case where the state only provides negative cases, this field is calculated as the summation of people who tested positive (“Positive Cases (People”) and the number of people who tested negative (“Negative (People or Cases)”). If we discover that a jurisdiction is including antigen tests in this metric, we will annotate that state or territory’s data accordingly.
                    """
            case .totalTests:
                return """
                    At the national level, this metric is a summary statistic which—because it sums figures from states reporting tests in test encounters with those reporting tests in specimens and in people—is an aggregate calculation of heterogeneous figures. Therefore, it should be contextualized as, at best, an estimate of national testing performance. In most states, the totalTestResults field is currently computed by adding positive and negative values because, historically, some states do not report totals, and to work around different reporting cadences for cases and tests. In Colorado, Delaware, the District of Columbia, Florida, Hawaii, Minnesota, Nevada, New York, North Dakota, Rhode Island, Virginia, Washington, and Wisconsin, where reliable testing encounters figures are available with a complete time series, we directly report those figures in this field. In Alabama, Alaska, Arkansas, Georgia, Indiana, Kentucky, Maryland, Massachusetts, Missouri, Nebraska, New Hampshire, Utah, and Vermont, where reliable specimens figures are available with a complete time series, we directly report those figures in this field. In Arizona, Idaho, and South Dakota, where reliable unique people figures are available with a complete time series, we directly report those figures in this field. We are in the process of switching all states over to use directly reported total figures, using a policy of preferring testing encounters, specimens, and people, in that order.
                    """
            case .everHospitalized:
                return "Total number of individuals who have ever been hospitalized with COVID-19. Definitions vary by state / territory. Where possible, we report hospitalizations with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .nowHopsitalized:
                return "Individuals who are currently hospitalized with COVID-19. Definitions vary by state / territory. Where possible, we report hospitalizations with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .everInICU:
                return "Total number of individuals who have ever been hospitalized in the Intensive Care Unit with COVID-19. Definitions vary by state / territory. Where possible, we report patients in the ICU with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .nowInICU:
                return "Individuals who are currently hospitalized in the Intensive Care Unit with COVID-19. Definitions vary by state / territory. Where possible, we report patients in the ICU with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .everOnVentilator:
                return "Total number of individuals who have ever been hospitalized under advanced ventilation with COVID-19. Definitions vary by state / territory. Where possible, we report patients on ventilation with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .nowOnVentilator:
                return "Individuals who are currently hospitalized under advanced ventilation with COVID-19. Definitions vary by state / territory. Where possible, we report patients on ventilation with confirmed or probable COVID-19 cases per the expanded CSTE case definition of April 5th, 2020 approved by the CDC."
            case .recovered:
                return "Total number of people that are identified as recovered from COVID-19. States provide very disparate definitions on what constitutes a “recovered” COVID-19 case. Types of “recovered” cases include those who are discharged from hospitals, released from isolation after meeting CDC guidance on symptoms cessation, or those who have not been identified as fatalities after a number of days (30 or more) post disease onset. Specifics vary for each state or territory."
            case .totalDeaths:
                return "Total fatalities with confirmed OR probable COVID-19 case diagnosis (per the expanded CSTE case definition of April 5th, 2020 approved by the CDC). In states where the information is available, it only tracks fatalities with confirmed OR probable COVID-19 case diagnosis where on the death certificate, COVID-19 is listed as an underlying cause of death according to WHO guidelines."
            case .probableDeaths:
                return "Total fatalities with probable COVID-19 case diagnosis (per the expanded CSTE case definition of April 5th, 2020 approved by the CDC). In states where the information is available, it only tracks fatalities with probable COVID-19 case diagnosis where on the death certificate, COVID-19 is listed as an underlying cause of death according to WHO guidelines."
            case .confirmedDeaths:
                return "Total fatalities with confirmed COVID-19 case diagnosis (per the expanded CSTE case definition of April 5th, 2020 approved by the CDC). In states where the information is available, it only tracks fatalities with confirmed COVID-19 case diagnosis where on the death certificate, COVID-19 is listed as an underlying cause of death according to WHO guidelines."
            case .deathIncrease:
                return "Total increase of fatalities with confirmed OR probable COVID-19 case diagnosis (per the expanded CSTE case definition of April 5th, 2020 approved by the CDC). In states where the information is available, it only tracks fatalities with confirmed OR probable COVID-19 case diagnosis where on the death certificate, COVID-19 is listed as an underlying cause of death according to WHO guidelines."
        }
    }
}

// MARK: - CustomStringConvertible

extension MetricType: CustomStringConvertible {
    var description: String {
        "\(self.rawValue)"
    }
}

#if DEBUG
extension MetricType {
    static let mock = Self.totalCases
}

extension Array where Element == MetricType {
    static var mock: Self {
        [.mock]
    }
}
#endif

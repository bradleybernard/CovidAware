//
//  StateDetailView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import SwiftUI

struct StateDetailView: View {
    @StateObject var viewModel: StateDetailViewModel

    private enum Spacing: CGFloat {
        case itemSpacing = 5
        case sectionSpacing = 15
    }

    private enum Identifiers: String {
        case scrollView
        case header
        case overview
        case cases
        case hospitalization
        case outcomes
        case pcr
        case antibody
    }

    var body: some View {
        ContainerView(viewModel: viewModel, content: content)
            .navigationTitle(viewModel.USAState.name)
    }

    @ViewBuilder
    private var content: some View {
        if let covidHistorical = viewModel.covidHistorical, let covidState = viewModel.covidState {
            contentView(covidHistorical: covidHistorical, covidState: covidState)
        } else {
            TryAgainView(kind: .invalidData) {
                viewModel.initialLoad()
            }
        }
    }

    private func contentView(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        GeometryReader { geometryProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.sectionSpacing.rawValue) {
                    ChartView(viewModel:
                        ChartViewModel(
                            covidHistorical: covidHistorical,
                            metricType: .newCasesToday,
                            chartConfiguration: makeChartConfiguration(covidHistorical: covidHistorical, width: geometryProxy.size.width),
                            currentProvider: viewModel.covidState
                        )
                    )
                    .frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
                    .padding(.bottom, Spacing.sectionSpacing.rawValue)

                    FavoriteButtonView(state: viewModel.covidState?.state)

                    overviewSection(covidHistorical: covidHistorical, covidState: covidState)
                    casesSection(covidHistorical: covidHistorical, covidState: covidState)
                    hospitalizationSection(covidHistorical: covidHistorical, covidState: covidState)
                    outcomesSection(covidHistorical: covidHistorical, covidState: covidState)
                    pcrSection(covidHistorical: covidHistorical, covidState: covidState)
                    antibodySection(covidHistorical: covidHistorical, covidState: covidState)
                    footerSection(covidHistorical: covidHistorical, geometryProxy: geometryProxy)
                }
                .id(Identifiers.scrollView.rawValue)
            }
        }
    }

    private func makeChartConfiguration(covidHistorical: CovidHistoricalMetrics<CovidState>, width: CGFloat) -> ChartConfiguration<CovidState> {
        ChartConfiguration(
            style: .title,
            title: "New cases this week",
            historicalRange: { covidHistorical in
                Array(covidHistorical.historical.prefix(7))
            },
            modifyMinXValue: { minXValue in
                minXValue
            },
            modifyMaxXValue: { maxXValue in
                maxXValue.tomorrow
            },
            calculateNumberOfXSections: { minXValue, maxXValue -> Int in
                maxXValue.days(from: minXValue) + 1
            },
            xSectionCalendarComponent: .day,
            unitsInSection: { numberOfXSections, xSectionIndex, _ -> Int in
                if xSectionIndex == 0 {
                    return 0
                }

                return 1
            },
            xSectionRange: { numberOfXSections in
                Array(0..<Int(numberOfXSections))
            },
            dateFormatter: CommonDateFormatters.day,
            chartWidth: width,
            drawingOptions: .init(
                pointSmoothness: 0,
                drawVerticalLines: true,
                drawHorizontalLines: true,
                drawCirclesOnPoints: true)
        )
    }

    private func footerSection(covidHistorical: CovidHistoricalMetrics<CovidState>, geometryProxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: Spacing.itemSpacing.rawValue) {
            StateDetailReportingGradeView(reportingGrade: viewModel.covidState?.dataQualityGrade)
                .frame(width: geometryProxy.size.width)
        }
    }

    private func overviewSection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.newCasesToday, .deathIncrease, .totalCases, .totalDeaths],
            title: "Overview",
            headerView: DateSelectionButtonView(covidHistorical: covidHistorical, covidProvider: $viewModel.covidState)
        )
        .id(Identifiers.overview.rawValue)
    }

    private func casesSection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView<CovidState, AnyView>(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.totalCases, .confirmedCases, .probableCases, .newCasesToday],
            title: "Cases",
            headerView: nil
        )
        .id(Identifiers.cases.rawValue)
    }

    private func pcrSection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView<CovidState, AnyView>(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.totalTestEncounters, .totalTestSpecimen, .totalTestPeople],
            title: "Viral (PCR) tests",
            headerView: nil
        )
        .id(Identifiers.pcr.rawValue)
    }

    private func antibodySection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView<CovidState, AnyView>(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.totalTests],
            title: "Antibody tests",
            headerView: nil
        )
        .id(Identifiers.antibody.rawValue)
    }

    private func hospitalizationSection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView<CovidState, AnyView>(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.everHospitalized, .nowHopsitalized, .everInICU, .nowInICU, .everOnVentilator, .nowOnVentilator],
            title: "Hospitalization",
            headerView: nil
        )
        .id(Identifiers.hospitalization.rawValue)
    }

    private func outcomesSection(covidHistorical: CovidHistoricalMetrics<CovidState>, covidState: CovidState) -> some View {
        MetricStatSectionView<CovidState, AnyView>(
            covidHistorical: covidHistorical,
            covidProvider: covidState,
            metricTypes: [.recovered, .totalDeaths, .probableDeaths, .confirmedDeaths],
            title: "Outcomes",
            headerView: nil
        )
        .id(Identifiers.outcomes.rawValue)
    }
}

#if DEBUG
struct StateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StateDetailViewModel(USAState: .mock)
        viewModel.viewState = .content
        viewModel.covidHistorical = .mock

        return NavigationView {
            StateDetailView(viewModel: viewModel)
        }
        .navigationTitle("Cancel")
    }
}
#endif

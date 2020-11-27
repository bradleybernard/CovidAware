//
//  USTodayView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/24/20.
//

import SwiftUI

struct USTodayView: View {
    @StateObject var viewModel: USTodayViewModel

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
            .navigationTitle("United States")
    }

    @ViewBuilder
    private var content: some View {
        if let covidHistorical = viewModel.covidCountryHistorical, let covidCountry = viewModel.covidCountry {
            contentView(covidHistorical: covidHistorical, covidCountry: covidCountry)
        } else {
            TryAgainView(kind: .invalidData) {
                viewModel.initialLoad()
            }
        }
    }

    private func contentView(covidHistorical: CovidHistoricalMetrics<CovidCountry>, covidCountry: CovidCountry) -> some View {
        GeometryReader { reader in
            ScrollViewReader { _ in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.sectionSpacing.rawValue) {
                        ChartView(viewModel:
                            ChartViewModel(
                                covidHistorical: covidHistorical,
                                metricType: .newCasesToday,
                                chartConfiguration: makeChartConfiguration(covidHistorical: covidHistorical, width: reader.size.width),
                                currentProvider: viewModel.covidCountry
                            )
                        )
                        .frame(width: reader.size.width, height: reader.size.height)
                        .padding(.bottom, Spacing.sectionSpacing.rawValue)

                        MetricStatSectionView(
                            covidHistorical: covidHistorical,
                            covidProvider: covidCountry,
                            metricTypes: [.newCasesToday, .deathIncrease, .totalCases, .totalDeaths],
                            title: "Overview",
                            headerView: DateSelectionButtonView(covidHistorical: covidHistorical, covidProvider: $viewModel.covidCountry))

                        Button("See data by State") {
                            viewModel.tappedStates()
                        }
                    }
                }
            }
        }
    }

    private func makeChartConfiguration(covidHistorical: CovidHistoricalMetrics<CovidCountry>, width: CGFloat) -> ChartConfiguration<CovidCountry> {
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
}

#if DEBUG
struct USTodayView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = USTodayViewModel {}
        viewModel.viewState = .content
        viewModel.covidCountryHistorical = CovidHistoricalMetrics(entity: .mock, historical: .mock)

        return USTodayView(viewModel: viewModel)
    }
}
#endif

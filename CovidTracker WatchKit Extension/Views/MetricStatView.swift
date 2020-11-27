//
//  MetricStatView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/14/20.
//

import SwiftUI

struct MetricStatView<CovidProvider: CovidMetricProvider>: View {
    let covidHistorical: CovidHistoricalMetrics<CovidProvider>
    let covidProvider: CovidProvider
    let metricType: MetricType

    var body: some View {
        if let formattedValue = formattedValue {
            NavigationLink(destination: chartView) {
                buttonView(formattedValue: formattedValue)
            }
        }
    }

    private var chartView: some View {
        ChartView(viewModel:
            ChartViewModel(
                covidHistorical: covidHistorical,
                metricType: metricType,
                chartConfiguration: chartConfiguration,
                currentProvider: covidProvider
            )
        )
        .navigationTitle(metricType.rawValue)
    }

    private var title: String? {
        if let entity = covidHistorical.entity as? CovidState {
            return entity.state.rawValue
        }

        return nil
    }

    private var chartConfiguration: ChartConfiguration<CovidProvider> {
        ChartConfiguration(
            style: .currentValue,
            title: title,
            historicalRange: { covidHistorical in
                covidHistorical.historical
            },
            modifyMinXValue: { minXValue in
                // Could show data from before start of recorded data:
                // minXValue = Date(timeIntervalSince1970: 1558630319).withoutTime.startOfMonth
                minXValue.startOfMonth
            },
            modifyMaxXValue: { maxXValue in
                maxXValue.withoutTime.nextMonth.endOfMonth
            },
            calculateNumberOfXSections: { minXValue, maxXValue -> Int in
                maxXValue.months(from: minXValue)
            },
            xSectionCalendarComponent: .month,
            unitsInSection: { numberOfXSections, xSectionIndex, sectionDate -> Int in
                guard let daysRange = Calendar.current.range(of: .day, in: .month, for: sectionDate) else {
                    fatalError("Could not get the number of days in a month")
                }

                let daysInMonth = daysRange.upperBound - 1

                // Minus one so the last line is drawn within bounds
                if xSectionIndex == 0 {
                    return daysInMonth - 1
                } else {
                    return daysInMonth
                }
            },
            xSectionRange: { numberOfXSections in
                Array(0..<Int(numberOfXSections))
            },
            dateFormatter: CommonDateFormatters.shortMonth,
            chartWidth: nil,
            drawingOptions: .init(
                pointSmoothness: 0,
                drawVerticalLines: true,
                drawHorizontalLines: true,
                drawCirclesOnPoints: false)
        )
    }

    @ViewBuilder
    private func buttonView(formattedValue: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(metricType.rawValue)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(formattedValue)
                .font(.headline)
                .foregroundColor(.white)

            MetricStatTrendView(
                covidHistorical: covidHistorical,
                covidProvider: covidProvider,
                metricType: metricType
            )
        }

        Spacer()
    }

    private var formattedValue: String? {
        guard let value = covidProvider[keyPath: metricType.valueKeyPath] else {
            return nil
        }

        return CommonNumberFormatters.numberFormatter.string(for: value)
    }
}

#if DEBUG
struct MetricStatView_Previews: PreviewProvider {
    static var previews: some View {
        MetricStatView<CovidState>(covidHistorical: .mock, covidProvider: .mock, metricType: .mock)
    }
}
#endif

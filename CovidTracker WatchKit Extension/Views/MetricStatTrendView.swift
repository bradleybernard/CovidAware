//
//  MetricStatTrendView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/27/20.
//

import SwiftUI

struct MetricStatTrendView<CovidProvider: CovidMetricProvider>: View {
    let covidHistorical: CovidHistoricalMetrics<CovidProvider>
    let covidProvider: CovidProvider
    let metricType: MetricType

    var body: some View {
        if let formattedValue = formattedValue {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                if let percentageChangeView = percentageChangeView {
                    percentageChangeView
                }

                Text(formattedValue)
                    .font(.system(size: 10))
            }
        }
    }

    private var previousValue: Int? {
        guard let covidProviderIndex = covidHistorical.historical.firstIndex(where: { currentProvider in
            currentProvider.date == covidProvider.date
        }) else {
            return nil
        }

        // Plus one since the array starts with the most recent date at index zero, so "previous" date would be index + 1
        let previousIndex = covidProviderIndex + 1
        guard previousIndex >= 0, previousIndex < covidHistorical.historical.count else {
            return nil
        }

        return covidHistorical.historical[previousIndex][keyPath: metricType.valueKeyPath]
    }

    private var difference: Int? {
        guard let previousValue = previousValue, let currentValue = currentValue else {
            return nil
        }

        return currentValue - previousValue
    }

    private var formattedValue: String? {
        guard let difference = difference, let formattedDifference = CommonNumberFormatters.numberFormatter.string(for: difference) else {
            return nil
        }

        // Number formatter includes negative sign if number is less than zero, but no positive sign
        let sign = difference < 0 ? "" : "+"
        return "\(sign)\(formattedDifference)"
    }

    private var percentageChangeView: Text? {
        // Can't divide by zero
        guard let previousValue = previousValue, let currentValue = currentValue, currentValue != .zero, currentValue != previousValue else {
            return nil
        }

        let percentageDifference = (Double(currentValue - previousValue) / Double(currentValue)) * 100.0

        guard let formattedDifference = CommonNumberFormatters.percentageFormatter.string(for: percentageDifference) else {
            return nil
        }

        let isIncreasing = currentValue > previousValue
        let imageName = isIncreasing ? "arrow.up.circle" : "arrow.down.circle"
        let color = isIncreasing ? metricType.increaseColor : metricType.decreaseColor

        return Text(Image(systemName: imageName))
            .foregroundColor(color)
            .font(.system(size: 10))

            + Text(" \(formattedDifference)%")
            .font(.system(size: 10))
    }

    private var currentValue: Int? {
        covidProvider[keyPath: metricType.valueKeyPath]
    }
}

#if DEBUG
struct MetricStatTrendView_Previews: PreviewProvider {
    static var previews: some View {
        MetricStatTrendView<CovidState>(covidHistorical: .mock, covidProvider: .mock, metricType: .mock)
    }
}
#endif

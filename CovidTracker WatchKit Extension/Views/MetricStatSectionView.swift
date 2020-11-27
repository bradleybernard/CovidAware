//
//  MetricStatSectionView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/24/20.
//

import SwiftUI

struct MetricStatSectionView<CovidProvider: CovidMetricProvider, Content: View>: View {
    let covidHistorical: CovidHistoricalMetrics<CovidProvider>
    let covidProvider: CovidProvider
    let metricTypes: [MetricType]
    let title: String

    // Introduced so the US today view can show the date selection button within the section
    let headerView: Content?

    private enum Spacing: CGFloat {
        case itemSpacing = 5
    }

    var body: some View {
        if shouldShowSection {
            VStack(alignment: .leading, spacing: Spacing.itemSpacing.rawValue) {
                ListSectionHeaderView(text: title)

                if let headerView = headerView {
                    headerView
                }

                ForEach(metricTypes, id: \.self) { metricType in
                    MetricStatView(covidHistorical: covidHistorical, covidProvider: covidProvider, metricType: metricType)
                }
            }
        }
    }

    private var shouldShowSection: Bool {
        metricTypes.first { metricType in
            covidProvider[keyPath: metricType.valueKeyPath] != nil
        } != nil
    }
}

#if DEBUG
struct MetricStatSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MetricStatSectionView<CovidState, AnyView>(covidHistorical: .mock, covidProvider: .mock, metricTypes: .mock, title: "Cases", headerView: nil)
    }
}
#endif

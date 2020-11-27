//
//  DateSelectionButtonView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/3/20.
//

import SwiftUI

// Identifiable & Hashable coming from SelectionListView requirements
struct DateSelectionButtonView<CovidProvider: CovidMetricProvider & Identifiable & Hashable>: View {
    let covidHistorical: CovidHistoricalMetrics<CovidProvider>

    @Binding var covidProvider: CovidProvider?
    @State var isPresented = false

    var body: some View {
        if let date = covidProvider?.date, let formattedDate = CommonDateFormatters.monthDayYear.string(for: date) {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text(formattedDate)
                    .font(.body)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
            })
            .sheet(isPresented: $isPresented) {
                SelectionListView(title: "Date", elements: covidHistorical.historical, selected: $covidProvider) { covidProvider in
                    Text(covidProvider.date, formatter: CommonDateFormatters.monthDayYear)
                        .font(.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }
}

#if DEBUG
struct DateSelectionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DateSelectionButtonView<CovidState>(covidHistorical: .mock, covidProvider: .constant(.mock))
    }
}
#endif

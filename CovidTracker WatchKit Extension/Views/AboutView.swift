//
//  AboutView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/27/20.
//

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var lifecycleManager: LifecycleManager
    @Environment(\.timeZone) var timezone: TimeZone

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 10) {
                Text("The data is sourced publicly from The COVID Tracking Project license CC BY 4.0.")
                Text("https://covidtracking.com/")
                    .font(.body )
                    .foregroundColor(.blue)
                Text("We do not alter the data in any way, shape, or form. We show the raw data in various visualizations.")
                Text("The Covid Tracking Project updates their Covid dataset every day around 7PM EST. Their data is double checked by humans before publishing.")

                if let nextRefreshDate = lifecycleManager.scheduledBackgroundRefreshDate {
                    Text("The app's next refresh date is set for: \(nextRefreshDate, formatter: CommonDateFormatters.monthDayYearTime) in your local timezone: \"\(timezone.identifier)\". At this time, the app will attempt to fetch the latest COVID data from The COVID Tracking Project, so you're always up to date.")
                }
            }
        }
        .navigationTitle("About")
    }
}

#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
#endif

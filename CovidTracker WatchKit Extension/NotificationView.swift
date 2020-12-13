//
//  NotificationView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/23/20.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Date(), formatter: CommonDateFormatters.monthDayYear)
                .font(.system(size: 10))
                .foregroundColor(.gray)

            Text("Check out today's new metrics!")
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
    }
}

#if DEBUG
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
#endif

//
//  ChartDateView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/25/20.
//

import SwiftUI

struct ChartDateView: View {
    let date: Date

    private enum Spacing: CGFloat {
        case itemSpacing = 0
        case maxWidth = 25
        case cornerRadius = 3
    }

    var body: some View {
        VStack(alignment: .center, spacing: Spacing.itemSpacing.rawValue) {
            monthView
            dayView
        }
    }

    private var dateText: String {
        let formattedDate = CommonDateFormatters.shortMonth.string(from: date)
        return formattedDate.uppercased()
    }

    private var monthView: some View {
        Text(dateText)
            .font(.system(size: 7))
            .frame(maxWidth: Spacing.maxWidth.rawValue)
            .background(Color.red)
            .cornerRadius(radius: Spacing.cornerRadius.rawValue, corners: [.topLeft, .topRight])
    }

    private var dayView: some View {
        Text(date, formatter: CommonDateFormatters.day)
            .font(.system(size: 15))
            .foregroundColor(.black)
            .frame(maxWidth: Spacing.maxWidth.rawValue)
            .background(Color.white)
            .cornerRadius(radius: Spacing.cornerRadius.rawValue, corners: [.bottomLeft, .bottomRight])
    }
}

#if DEBUG
struct ChartDateView_Previews: PreviewProvider {
    static var previews: some View {
        ChartDateView(date: .init())
    }
}
#endif

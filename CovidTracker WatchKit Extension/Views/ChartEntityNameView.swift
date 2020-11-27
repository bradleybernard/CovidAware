//
//  ChartEntityNameView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/25/20.
//

import SwiftUI

struct ChartEntityNameView<CovidProvider: CovidMetricProvider>: View {
    let covidProvider: CovidProvider?

    private enum Spacing: CGFloat {
        case cornerRadius = 4
    }

    private enum Padding: CGFloat {
        case leftRight = 4
        case topBottom = 7
    }

    var body: some View {
        Text(name)
            .font(.system(size: 12))
            .foregroundColor(textColor)
            .padding([.leading, .trailing], Padding.leftRight.rawValue)
            .padding([.top, .bottom], Padding.topBottom.rawValue)
            .background(backgroundColor)
            .cornerRadius(Spacing.cornerRadius.rawValue)
    }

    private var name: String {
        if let covidProvider = covidProvider as? CovidState {
            return covidProvider.state.rawValue
        }

        return "US"
    }

    private var backgroundUIColor: UIColor {
        if let covidProvider = covidProvider as? CovidState {
            return covidProvider.state.uiColor
        }

        return .white
    }

    private var backgroundColor: Color {
        Color(backgroundUIColor)
    }

    private var textColor: Color {
        return Color(backgroundUIColor.contrast)
    }
}

#if DEBUG
struct ChartEntityNameView_Previews: PreviewProvider {
    static var previews: some View {
        ChartEntityNameView<CovidState>(covidProvider: .mock)
        ChartEntityNameView<CovidCountry>(covidProvider: .mock)
    }
}
#endif

//
//  InfoView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/23/20.
//

import SwiftUI

struct InfoView: View {
    let title: String
    let description: String

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.3)

                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.gray)
            }
        }
    }
}

#if DEBUG
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(title: "Reporting grade", description: "Used to measure how well a state reports COVID-19 metrics.")
    }
}
#endif

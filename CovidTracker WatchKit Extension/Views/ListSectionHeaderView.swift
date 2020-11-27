//
//  ListSectionHeaderView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/14/20.
//

import SwiftUI

struct ListSectionHeaderView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
            Divider()
        }
    }
}

#if DEBUG
struct ListSectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListSectionHeaderView(text: MetricType.mock.rawValue)
    }
}
#endif

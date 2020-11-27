//
//  StateCellView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/27/20.
//

import SwiftUI

struct StateCellView: View {
    let USAState: USAState
    let style: StateCellView.Style

    enum Style {
        case short
        case long
    }

    var body: some View {
        Text(text)
    }

    private var text: String {
        switch style {
            case .long:
                return USAState.name
            case .short:
                return USAState.rawValue
        }
    }
}

#if DEBUG
struct StateCellView_Previews: PreviewProvider {
    static var previews: some View {
        StateCellView(USAState: .mock, style: .long)
        StateCellView(USAState: .mock, style: .short)
    }
}
#endif

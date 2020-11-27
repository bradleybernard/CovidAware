//
//  TryAgainView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/25/20.
//

import SwiftUI

struct TryAgainView: View {
    enum Kind: CaseIterable {
        case error
        case noData
        case invalidData
    }

    let kind: Kind
    let action: (() -> Void)

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(messageForKind)

            Button("Try again") {
                action()
            }
        }
    }

    private var messageForKind: String {
        switch kind {
            case .error:
                return "An error occurred."
            case .noData:
                return "No data available."
            case .invalidData:
                return "Invalid data."
        }
    }
}

#if DEBUG
struct TryAgainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(TryAgainView.Kind.allCases, id: \.self) { kind in
                TryAgainView(kind: kind) {}
            }
        }
    }
}
#endif

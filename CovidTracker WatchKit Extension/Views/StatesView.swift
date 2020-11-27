//
//  StatesView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/26/20.
//

import SwiftUI

struct StatesView: View {
    @EnvironmentObject var userDefaultsStorage: UserDefaultsStorage
    @State var selectedStateTag: Int?

    private static let columns = 3
    private static let itemSize: CGFloat = 50
    private static let gridItemLayout = [
        GridItem(.adaptive(minimum: Self.itemSize))
    ]

    var body: some View {
        ScrollView {
            if !userDefaultsStorage.favoriteStates.isEmpty {
                LazyVStack(alignment: .leading, spacing: 5) {
                    Text("Favorites")
                    Divider()

                    ForEach(userDefaultsStorage.favoriteStates.sorted(by: \.name), id: \.self) { favoriteState in
                        Button(action: {
                            selectedStateTag = Self.tagForState(USAState: favoriteState)
                        }, label: {
                            StateCellView(USAState: favoriteState, style: .long)
                        })
                    }

                    Divider()
                }
            }

            // Manually create LazyVGrid since we need to be able to navigate to any state,
            // No matter how far down in the list it is by tag (ID), and since it was lazy
            // it wouldn't be able to find that tag if we referenced a state that was offscreen
            // so all views need to be created for each state, so favorites navigation works
            ForEach(0..<USAState.allCases.count / Self.columns) { row in
                HStack {
                    ForEach(0..<Self.columns) { column in
                        NavigationLink(
                            destination: StateDetailView(viewModel: StateDetailViewModel(USAState: Self.stateFor(row: row, column: column))),
                            tag: Self.tagForState(USAState: Self.stateFor(row: row, column: column)),
                            selection: $selectedStateTag
                        ) {
                            StateCellView(USAState: Self.stateFor(row: row, column: column), style: .short)
                        }
                        .id(Self.tagForState(USAState: Self.stateFor(row: row, column: column)))
                        .frame(width: Self.itemSize, height: Self.itemSize)
                    }
                }
            }
        }
        .navigationTitle("States")
    }

    private static func stateFor(row: Int, column: Int) -> USAState {
        let index = (row * Self.columns) + column
        let allStates = USAState.allCases

        // Return dummy state if index check fails
        guard index >= 0, index < allStates.count else {
            return .alabama
        }

        return allStates[index]
    }

    private static func tagForState(USAState: USAState) -> Int {
        let asciiString = USAState.rawValue.compactMap { character -> String? in
            guard let asciiValue = character.asciiValue else {
                return nil
            }

            return String(asciiValue)
        }
        .joined()

        guard let intValue = Int(asciiString) else {
            return .zero
        }

        return intValue
    }
}

#if DEBUG
struct StatesView_Previews: PreviewProvider {
    static var previews: some View {
        StatesView()
    }
}
#endif

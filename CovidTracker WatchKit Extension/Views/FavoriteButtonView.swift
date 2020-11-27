//
//  FavoriteButtonView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/23/20.
//

import SwiftUI

struct FavoriteButtonView: View {
    let state: USAState?

    @EnvironmentObject var userDefaultsStorage: UserDefaultsStorage

    var isFavorite: Bool {
        guard let state = state else {
            return false
        }

        return userDefaultsStorage.favoriteStates.contains(state)
    }

    var body: some View {
        Button(action: {
            favoriteButtonTapped()
        }, label: {
            Text(Image(systemName: heartImage))
                .foregroundColor(color)

                + Text("Favorite")
        })
        .animation(.default)
    }

    func favoriteButtonTapped() {
        guard let state = state else {
            return
        }

        if isFavorite, let index = userDefaultsStorage.favoriteStates.firstIndex(of: state) {
            userDefaultsStorage.favoriteStates.remove(at: index)
        } else {
            userDefaultsStorage.favoriteStates.append(state)
        }
    }

    private var color: Color {
        isFavorite ? .red : .white
    }

    private var heartImage: String {
        isFavorite ? "heart.fill" : "heart"
    }
}

#if DEBUG
struct FavoriteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButtonView(state: .mock)
            .environmentObject(UserDefaultsStorage())
    }
}
#endif

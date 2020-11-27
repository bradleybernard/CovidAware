//
//  GreenOutlineButtonStyle.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/26/20.
//

import SwiftUI

struct GreenOutlineButtonStyle: ButtonStyle {
    private static let cornerRadius: CGFloat = 8
    private static let opacity: Double = 0.2

    private static let scaledDown: CGFloat = 0.97
    private static let scaledUp: CGFloat = 1.0

    private static let topBottomPadding: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding([.top, .bottom], Self.topBottomPadding)
            .background(Color(Colors.grayBackground))
            .cornerRadius(Self.cornerRadius)
            .scaleEffect(scaleEffectSize(configuration: configuration))
            .overlay(
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .stroke(Color.green)
                    .scaleEffect(scaleEffectSize(configuration: configuration))
            )
            .overlay(
                overlayBackground(configuration: configuration)
            )
    }

    @ViewBuilder
    private func overlayBackground(configuration: Configuration) -> some View {
        if configuration.isPressed {
            Color.black
                .opacity(Self.opacity)
                .blendMode(.darken)
        }
    }

    private func scaleEffectSize(configuration: Configuration) -> CGSize {
        CGSize(
            width: configuration.isPressed ? Self.scaledDown : Self.scaledUp,
            height: configuration.isPressed ? Self.scaledDown : Self.scaledUp
        )
    }
}

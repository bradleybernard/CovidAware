//
//  SelectionButtonStyle.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/3/20.
//

import SwiftUI

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    private struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

struct SelectionButtonStyle: ButtonStyle {
    enum Position {
        case first
        case middle
        case last

        init(position: Int, count: Int) {
            if position == .zero {
                self = .first
            } else if position == count - 1 {
                self = .last
            } else {
                self = .middle
            }
        }

        var corners: UIRectCorner {
            switch self {
                case .first:
                    return [.topLeft, .topRight]
                case .middle:
                    return .init()
                case .last:
                    return [.bottomLeft, .bottomRight]
            }
        }
    }

    let position: Position

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(Colors.grayBackground))
            .cornerRadius(radius: 8, corners: position.corners)
    }
}

//
//  View+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 9/27/20.
//

import SwiftUI

extension View {
    // MARK: - If/Let conditional

    @ViewBuilder
    func ifLet<V, Transform: View>(
        _ value: V?,
        transform: (Self, V) -> Transform
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Button style custom corner radius

    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }

    // MARK: - Border only for some edges

    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }

    // MARK: - Debug

    func printDebug(_ value: Any) -> Self {
        Swift.print(value)
        return self
    }

    func debugAction(_ closure: (Self) -> Void) -> Self {
        #if DEBUG
        closure(self)
        #endif

        return self
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var xCoordinate: CGFloat {
                switch edge {
                    case .top, .bottom, .leading: return rect.minX
                    case .trailing: return rect.maxX - width
                }
            }

            var yCoordinate: CGFloat {
                switch edge {
                    case .top, .leading, .trailing: return rect.minY
                    case .bottom: return rect.maxY - width
                }
            }

            var width: CGFloat {
                switch edge {
                    case .top, .bottom: return rect.width
                    case .leading, .trailing: return self.width
                }
            }

            var height: CGFloat {
                switch edge {
                    case .top, .bottom: return self.width
                    case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: xCoordinate, y: yCoordinate, width: width, height: height)))
        }
        return path
    }
}

//
//  ReportingGradeView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 10/13/20.
//

import SwiftUI

struct ReportingGradeView: View {
    let reportingGrade: ReportingGrade

    private enum Spacing: CGFloat {
        case innerSpace = 0
        case lineWidth = 5
        case padding = 3
        case size = 70
    }

    private static let letterAnimation = Animation
        .easeInOut(duration: 0.6)
        .delay(0.3)

    private static let ringAnimation = Animation
        .easeInOut(duration: 0.6)
        .delay(0.3)

    @State private var percentage: CGFloat = 0
    @State private var showGradeText = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: Spacing.lineWidth.rawValue, lineCap: .round, lineJoin: .round))
                .padding(.top, topBottomPadding)
                .padding(.bottom, topBottomPadding)
                .frame(width: Spacing.size.rawValue, height: Spacing.size.rawValue)

            Circle()
                .trim(from: 0 + Spacing.innerSpace.rawValue, to: percentage - Spacing.innerSpace.rawValue)
                .stroke(style: StrokeStyle(lineWidth: Spacing.lineWidth.rawValue, lineCap: .round, lineJoin: .round))
                .transition(.opacity)
                .rotationEffect(.degrees(-90))
                .foregroundColor(colorForGrade)
                .padding(.top, topBottomPadding)
                .padding(.bottom, topBottomPadding)
                .animation(Self.ringAnimation)
                .overlay(overlayView)
                .frame(width: Spacing.size.rawValue, height: Spacing.size.rawValue)
                .onAppear {
                    percentage = percentageForGrade
                    showGradeText = true
                }
        }
    }

    private var topBottomPadding: CGFloat {
        (Spacing.lineWidth.rawValue / 2) + Spacing.padding.rawValue
    }

    private var letterForGrade: String {
        reportingGrade.rawValue
    }

    private var colorForGrade: Color {
        switch reportingGrade {
            case .aPlus, .a, .aMinus:
                return .green
            case .bPlus, .b, .bMinus:
                return .blue
            case .cPlus, .c, .cMinus:
                return .yellow
            case .dPlus, .d, .dMinus:
                return .orange
            case .f:
                return .red
        }
    }

    private var percentageForGrade: CGFloat {
        let maxValue: CGFloat = 1.0
        let fValue: CGFloat = 0.25
        let gradesAboveF: CGFloat = 12

        let incremement = (maxValue - fValue) / gradesAboveF

        switch reportingGrade {
            case .aPlus:
                return maxValue
            case .a:
                return maxValue
            case .aMinus:
                return fValue + (incremement * 10)
            case .bPlus:
                return fValue + (incremement * 9)
            case .b:
                return fValue + (incremement * 8)
            case .bMinus:
                return fValue + (incremement * 7)
            case .cPlus:
                return fValue + (incremement * 6)
            case .c:
                return fValue + (incremement * 5)
            case .cMinus:
                return fValue + (incremement * 4)
            case .dPlus:
                return fValue + (incremement * 3)
            case .d:
                return fValue + (incremement * 2)
            case .dMinus:
                return fValue + (incremement * 1)
            case .f:
                return fValue
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        Group {
            if showGradeText {
                Text(letterForGrade)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .animation(Self.letterAnimation)
    }
}

#if DEBUG
struct ReportingGradeView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(ReportingGrade.allCases, id: \.self) { reportingGrade in
                ReportingGradeView(reportingGrade: reportingGrade)
            }
        }
    }
}
#endif

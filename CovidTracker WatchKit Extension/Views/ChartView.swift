//
//  ChartView.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/25/20.
//

import SwiftUI

struct ChartView<CovidProvider: CovidMetricProvider>: View {
    @StateObject var viewModel: ChartViewModel<CovidProvider>
    @State var isPresented = false

    @State var previousLocation: CGPoint?

    private enum Identifier: String {
        case chartView
    }

    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { scrollViewReader in
                VStack(alignment: .leading, spacing: 0) {
                    headerView

                    HStack(alignment: .top, spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            chartView(reader: reader)
                                .id(Identifier.chartView.rawValue)
                                .offset(x: chartXOffset)
                        }
                        .frame(width: reader.size.width - ChartConstants.yAxisLabelWidth)
                        .disabled(true)
                        .onChange(of: isPresented) { _ in
                            guard isPresented else {
                                return
                            }

                            // Wait for sheet to be presented (300ms) then save current shown index
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
                                viewModel.startingIndex = Int(viewModel.currentIndex)
                                viewModel.currentIndex = 0
                            }
                        }

                        yAxisLabelView(reader: reader)
                            .offset(y: -(ChartConstants.textHeight / 2))
                    }
                    .frame(width: reader.size.width, height: reader.size.height)
                    .onAppear {
                        if viewModel.chartConfiguration.chartWidth == nil {
                            scrollViewReader.scrollTo(Identifier.chartView.rawValue, anchor: .trailing)
                        }

                        // Need to layout first, then update current index
                        DispatchQueue.main.async {
                            viewModel.setCurrentIndex()
                        }
                    }
                    .if(viewModel.chartConfiguration.style == .currentValue) { view in
                        view.gesture(dragGesture)
                            .focusable(true)
                            .digitalCrownRotation($viewModel.currentIndex, from: 0, through: Double(viewModel.chartData.points.count) - 1, by: 1.0, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: false)
                    }
                }
                .sheet(isPresented: $isPresented) {
                    InfoView(title: viewModel.metricType.rawValue, description: viewModel.metricType.definition)
                }
            }
            .offset(y: (ChartConstants.textHeight / 2))
        }
        .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    }

    @ViewBuilder
    private var headerView: some View {
        if viewModel.chartConfiguration.style == .currentValue, let currentPoint = viewModel.currentPoint {
            HStack(alignment: .center, spacing: 5) {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("\(currentPoint.value)")
                        .font(Font.system(size: 14).bold())
                        .foregroundColor(Color.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                })
                .buttonStyle(GreenOutlineButtonStyle())

                ChartDateView(date: currentPoint.date)
            }
            .padding([.leading, .trailing, .bottom])
        } else if viewModel.chartConfiguration.style == .title, let title = viewModel.chartConfiguration.title {
            Text(title)
                .font(Font.system(size: 14).bold())
                .foregroundColor(Color.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.bottom, 2)
        }
    }

    private var chartXOffset: CGFloat {
        guard viewModel.chartConfiguration.style == .currentValue, let currentPoint = viewModel.currentPoint else {
            return .zero
        }

        let offset = (CGFloat(currentPoint.xValue) * viewModel.chartData.xPixelsPerUnit)
        return viewModel.chartData.chartWidth - offset
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard viewModel.chartConfiguration.style == .currentValue else {
                    return
                }

                defer {
                    previousLocation = value.location
                }

                guard let previousLocation = previousLocation else {
                    return
                }

                let xDistance = value.location.x - previousLocation.x
                let indexChange = xDistance / (viewModel.chartData.xPixelsPerUnit)
                let currentIndex = Int(viewModel.currentIndex)
                let newIndex = currentIndex + Int(indexChange)

                guard newIndex >= 0, newIndex < viewModel.chartData.points.count else {
                    return
                }

                viewModel.currentIndex = Double(newIndex)
            }
            .onEnded { _ in
                previousLocation = nil
            }
    }

    private func calculateChartHeight(reader: GeometryProxy) -> CGFloat {
        let buttonHeight: CGFloat = 27
        let buttonBottomPadding: CGFloat = 14

        var totalHeight = reader.size.height - ChartConstants.xAxisLabelHeight

        if viewModel.chartConfiguration.style == .currentValue {
            totalHeight -= buttonHeight + buttonBottomPadding
        }

        if viewModel.chartConfiguration.drawingOptions.drawCirclesOnPoints {
            totalHeight -= ChartConstants.circleRadius * 2
        }

        return totalHeight
    }

    @ViewBuilder
    private func yAxisLabelView(reader: GeometryProxy) -> some View {
        let chartHeight = calculateChartHeight(reader: reader)
        let ySectionHeight = chartHeight / CGFloat(viewModel.yAxisData.numberOfSections)

        VStack(alignment: .leading, spacing: ySectionHeight - ChartConstants.textHeight) {
            // Draw yAxis labels
            ForEach(viewModel.yAxisData.labels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func chartView(reader: GeometryProxy) -> some View {
        let chartHeight = calculateChartHeight(reader: reader)
        let ySectionHeight = chartHeight / CGFloat(viewModel.yAxisData.numberOfSections)

        let yUnitsPerValue = chartHeight / viewModel.chartData.yDifference
        let points = viewModel.chartData.points.map { chartPoint -> CGPoint in
            let xCoordinate = CGFloat(chartPoint.xValue) * viewModel.chartData.xPixelsPerUnit
            let yCoordinate = chartHeight - (yUnitsPerValue * CGFloat(chartPoint.yValue))
            return CGPoint(x: xCoordinate, y: yCoordinate)
        }

        // Lays out left to right, offset of x: 30 is an offset shifting right 30 points from left
        // Lays out top to bottom, offset of y: 30 is an offset shifting down 30 points from top
        ZStack(alignment: .topLeading) {
            // Draw vertical lines
            veritcalLinesPath(chartHeight: chartHeight)

            // Create xAxis labels
            xAxisLabelsView(chartHeight: chartHeight)

            // Draw horizontal lines
            horizontalLinesPath(chartHeight: chartHeight, ySectionHeight: ySectionHeight)

            // Draw each points forming a line in the chart
            pointsPath(points: points)

            // Draw current line
            currentLinePath(chartHeight: chartHeight)

            // Draw circles around each point
            pointCirclesPath(points: points)
        }
        .frame(width: chartWidth, height: reader.size.height, alignment: .center)
        .offset(x: viewModel.chartData.xOffset, y: viewModel.chartData.yOffset)
        // Use metal to draw this offscreen and return an image to flatten the views
        .drawingGroup()
    }

    private var chartWidth: CGFloat {
        if viewModel.chartConfiguration.drawingOptions.drawCirclesOnPoints {
            return viewModel.chartData.chartWidth + ChartConstants.circleRadius
        }

        return viewModel.chartData.chartWidth
    }

    @ViewBuilder
    private func pointCirclesPath(points: [CGPoint]) -> some View {
        if viewModel.chartConfiguration.drawingOptions.drawCirclesOnPoints {
            ForEach(points, id: \.self) { point in
                Path { path in
                    path.addArc(center: point, radius: ChartConstants.circleRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: true)
                }
                .fill(Color.white)
            }
        }
    }

    @ViewBuilder
    private func pointsPath(points: [CGPoint]) -> some View {
        var previousPoint = points.first ?? .zero

        Path { path in
            path.move(to: previousPoint)

            points.forEach { point in
                let controlPoint = controlPoints(pointOne: previousPoint, pointTwo: point, smoothness: viewModel.chartConfiguration.drawingOptions.pointSmoothness)
                path.addCurve(to: point, control1: controlPoint.one, control2: controlPoint.two)
                previousPoint = point
            }
        }
        .stroke(Color.red, style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
    }

    @ViewBuilder
    private func xAxisLabelsView(chartHeight: CGFloat) -> some View {
        ForEach(viewModel.xAxisData.labelPoints, id: \.offset) { labelPoint in
            Text(labelPoint.label)
                .font(.system(size: 10))
                .foregroundColor(Color.gray)
                .offset(x: labelPoint.offset + 1, y: chartHeight)
        }
    }

    @ViewBuilder
    private func veritcalLinesPath(chartHeight: CGFloat) -> some View {
        if viewModel.chartConfiguration.drawingOptions.drawVerticalLines {
            Path { path in
                viewModel.xAxisData.lines.forEach { offset in
                    path.move(to: .init(x: offset, y: .zero))
                    path.addLine(to: .init(x: offset, y: chartHeight))
                }
            }
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.0, lineCap: .butt, lineJoin: .bevel, miterLimit: 0, dash: [3], dashPhase: 2))
        } else {
            Path { path in
                if let offset = viewModel.xAxisData.lines.last {
                    path.move(to: .init(x: offset, y: .zero))
                    path.addLine(to: .init(x: offset, y: chartHeight))
                }
            }
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.0, lineCap: .butt, lineJoin: .bevel, miterLimit: 0, dash: [3], dashPhase: 2))
        }
    }

    @ViewBuilder
    private func horizontalLinesPath(chartHeight: CGFloat, ySectionHeight: CGFloat) -> some View {
        if viewModel.chartConfiguration.drawingOptions.drawHorizontalLines {
            Path { path in
                viewModel.yAxisData.sectionIndexes.forEach { sectionIndex in
                    let yCoordinate = CGFloat(sectionIndex) * ySectionHeight
                    path.move(to: .init(x: .zero, y: yCoordinate))
                    path.addLine(to: .init(x: viewModel.chartData.chartWidth, y: yCoordinate))
                }
            }
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.0, lineCap: .butt, lineJoin: .bevel, miterLimit: 0, dash: [], dashPhase: 0))
        } else {
            Path { path in
                if let sectionIndex = viewModel.yAxisData.sectionIndexes.last {
                    let yCoordinate = CGFloat(sectionIndex) * ySectionHeight
                    path.move(to: .init(x: .zero, y: yCoordinate))
                    path.addLine(to: .init(x: viewModel.chartData.chartWidth, y: yCoordinate))
                }
            }
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.0, lineCap: .butt, lineJoin: .bevel, miterLimit: 0, dash: [], dashPhase: 0))
        }
    }

    @ViewBuilder
    private func currentLinePath(chartHeight: CGFloat) -> some View {
        // Draw current line
        if viewModel.chartConfiguration.style == .currentValue, let currentPointX = viewModel.currentPoint?.xValue {
            Path { path in
                let xCoordinate = CGFloat(currentPointX) * viewModel.chartData.xPixelsPerUnit
                path.move(to: .init(x: xCoordinate, y: .zero))
                path.addLine(to: .init(x: xCoordinate, y: chartHeight))
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 1.0, lineCap: .round, lineJoin: .round))
        }
    }

    private func controlPoints(pointOne: CGPoint, pointTwo: CGPoint, smoothness: CGFloat) -> (one: CGPoint, two: CGPoint) {
        let percent = min(1, max(0, smoothness))

        let controlPointOne = makeControlPoint(pointOne: pointOne, pointTwo: pointTwo, percent: percent)
        let controlPointTwo = makeControlPoint(pointOne: pointOne, pointTwo: pointTwo, percent: percent)

        return (controlPointOne, controlPointTwo)
    }

    private func makeControlPoint(pointOne: CGPoint, pointTwo: CGPoint, percent: CGFloat) -> CGPoint {
        var controlPoint = pointOne

        // Apply smoothness
        let xCoord0 = max(pointOne.x, pointTwo.x)
        let xCoord1 = min(pointOne.x, pointTwo.x)
        let xCoord = xCoord0 + (xCoord1 - xCoord0) * percent
        controlPoint.x = xCoord

        return controlPoint
    }
}

#if DEBUG
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        let configuration = ChartConfiguration<CovidState>(
            style: .plain,
            title: USAState.california.rawValue,
            historicalRange: { covidHistoricalProvider in
                Array(covidHistoricalProvider.historical.prefix(7))
            },
            modifyMinXValue: { minXValue in
                minXValue
            },
            modifyMaxXValue: { maxXValue in
                maxXValue.tomorrow
            },
            calculateNumberOfXSections: { minXValue, maxXValue -> Int in
                maxXValue.days(from: minXValue) + 1
            },
            xSectionCalendarComponent: .day,
            unitsInSection: { numberOfXSections, xSectionIndex, _ -> Int in
                if xSectionIndex == 0 {
                    return 0
                }

                return 1
            },
            xSectionRange: { numberOfXSections in
                Array(0..<Int(numberOfXSections))
            },
            dateFormatter: CommonDateFormatters.day,
            chartWidth: 200,
            drawingOptions: .init(
                pointSmoothness: 0,
                drawVerticalLines: true,
                drawHorizontalLines: true,
                drawCirclesOnPoints: true)
        )

        ChartView(viewModel: ChartViewModel(covidHistorical: .mock, metricType: .mock, chartConfiguration: configuration))
    }
}
#endif

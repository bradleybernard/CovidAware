//
//  ChartViewModel.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/25/20.
//

import SwiftUI
import os

class XAxisData {
    struct LabelPoint {
        let offset: CGFloat
        let label: String
    }

    let pixelsPerUnit: CGFloat

    var lines: [CGFloat] = []
    var labelPoints: [LabelPoint] = []

    init(pixelsPerUnit: CGFloat) {
        self.pixelsPerUnit = pixelsPerUnit
    }

    func addLine(for units: Int, addingPrevious: Bool = true) {
        var previousOffset: CGFloat = 0

        if addingPrevious {
            previousOffset = lines.last ?? .zero
        }

        let newOffset = (CGFloat(units) * pixelsPerUnit) + previousOffset

        lines.append(newOffset)
    }

    func addLabel(_ label: String, at units: Int, addingPrevious: Bool = true) {
        var previousOffset: CGFloat = 0

        if addingPrevious {
            previousOffset = labelPoints.last?.offset ?? .zero
        }

        let newOffset = (CGFloat(units) * pixelsPerUnit) + previousOffset

        labelPoints.append(LabelPoint(offset: newOffset, label: label))
    }
}

class YAxisData {
    let numberOfSections: Int
    let sectionIndexes: [Int]
    var labels: [String] = []

    init(numberOfSections: Int) {
        self.numberOfSections = numberOfSections
        sectionIndexes = Array(0...numberOfSections)
    }
}

class ChartData {
    var minYValue: Int = .max
    var maxYValue: Int = .min

    var now = Date().withoutTime
    var minXValue: Date
    var maxXValue: Date

    var numberOfXSections: Int = 0
    var points: [ChartPoint] = []

    var chartWidth: CGFloat = 0
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0

    var xPixelsPerUnit: CGFloat = 0
    var yDifference: CGFloat = 0

    init(minXValue: Date, maxXValue: Date) {
        self.minXValue = minXValue
        self.maxXValue = maxXValue
    }
}

struct ChartPoint: CustomStringConvertible {
    let date: Date
    let value: Int

    let xValue: Int
    let yValue: Int

    var description: String {
        "(date: \(date), value: \(value), xValue: \(xValue), yValue: \(yValue))"
    }
}

enum ChartConstants {
    static let numberOfYAxisSections = 3

    static let textHeight: CGFloat = 12
    static let xPixelsPerUnit: CGFloat = 1.3 // from: 40px / 30 days
    static let yAxisLabelWidth: CGFloat = 25
    static let xAxisLabelHeight: CGFloat = 12

    static let circleRadius: CGFloat = 2
    static let pointSmoothness: CGFloat = 0.5
}

struct ChartConfiguration<CovidProvider: CovidMetricProvider> {
    struct DrawingOptions {
        let pointSmoothness: CGFloat
        let drawVerticalLines: Bool
        let drawHorizontalLines: Bool
        let drawCirclesOnPoints: Bool
    }

    enum Style {
        case plain
        case title
        case currentValue
    }

    let style: Style
    let title: String?

    let historicalRange: ((CovidHistoricalMetrics<CovidProvider>) -> [CovidProvider])
    let modifyMinXValue: ((Date) -> Date)
    let modifyMaxXValue: ((Date) -> Date)

    let calculateNumberOfXSections: ((Date, Date) -> Int)
    let xSectionCalendarComponent: Calendar.Component
    let unitsInSection: ((Int, Int, Date) -> Int)
    let xSectionRange: ((Int) -> [Int])

    let dateFormatter: DateFormatter
    let chartWidth: CGFloat?
    let drawingOptions: DrawingOptions
}

class ChartViewModel<CovidProvider: CovidMetricProvider>: ObservableObject {
    let covidHistorical: CovidHistoricalMetrics<CovidProvider>
    let metricType: MetricType
    let chartConfiguration: ChartConfiguration<CovidProvider>

    var startingIndex: Int?

    @Published var currentIndex: Double = 0
    @Published var offset: CGPoint = .zero

    @Published var xAxisData: XAxisData
    @Published var yAxisData: YAxisData
    @Published var chartData: ChartData

    init(covidHistorical: CovidHistoricalMetrics<CovidProvider>, metricType: MetricType, chartConfiguration: ChartConfiguration<CovidProvider>, currentProvider: CovidProvider? = nil) {
        self.covidHistorical = covidHistorical
        self.metricType = metricType
        self.chartConfiguration = chartConfiguration

        let chartData = Self.makeChartData(
            covidHistorical: covidHistorical,
            metricType: metricType,
            chartConfiguration: chartConfiguration,
            currentProvider: currentProvider
        )

        self.xAxisData = Self.makeXAxisData(chartData: chartData, chartConfiguration: chartConfiguration)
        self.yAxisData = Self.makeYAxisData(chartData: chartData)
        self.chartData = chartData

        // Find and store starting index if set
        if let currentProvider = currentProvider {
            if let providerIndex = chartData.points.firstIndex(where: { chartPoint in
                chartPoint.date == currentProvider.date.withoutTime
            }) {
                startingIndex = providerIndex
            }
        }
    }

    var currentPoint: ChartPoint? {
        let index = Int(currentIndex)
        guard index >= 0, index < chartData.points.endIndex else {
            return nil
        }

        return chartData.points[index]
    }

    func setCurrentIndex() {
        guard let startingIndex = startingIndex else {
            return
        }

        currentIndex = Double(startingIndex)
        self.startingIndex = nil
    }

    // swiftlint:disable function_body_length
    private static func makeChartData(
        covidHistorical: CovidHistoricalMetrics<CovidProvider>,
        metricType: MetricType,
        chartConfiguration: ChartConfiguration<CovidProvider>,
        currentProvider: CovidProvider?
    ) -> ChartData {
        let covidHistoricalRange = chartConfiguration.historicalRange(covidHistorical)

        guard let lastElement = covidHistoricalRange.last, let firstElement = covidHistoricalRange.first else {
            fatalError("No data for chart")
        }

        var minXValue = lastElement.date.withoutTime
        var maxXValue = firstElement.date.withoutTime

        var minYValue: Int = .max
        var maxYValue: Int = .min

        var chartPoints: [ChartPoint] = []

        chartConfiguration.historicalRange(covidHistorical).forEach { covidProvider in
            guard let value = covidProvider[keyPath: metricType.valueKeyPath] else {
                os_log("Missing data for: \(covidProvider.date) for metric: \(metricType)")
                return
            }

            let date = covidProvider.date.withoutTime

            minXValue = min(minXValue, date)
            maxXValue = max(maxXValue, date)

            minYValue = min(minYValue, value)
            maxYValue = max(maxYValue, value)

            // Will overwrite xValue later
            let chartPoint = ChartPoint(date: date, value: value, xValue: 0, yValue: value)
            chartPoints.append(chartPoint)
        }

        let chartData = ChartData(minXValue: minXValue, maxXValue: maxXValue)
        chartData.minYValue = minYValue
        chartData.maxYValue = maxYValue
        chartData.points = chartPoints

        os_log("Min X value: \(chartData.minXValue)")
        os_log("Max X value: \(chartData.maxXValue)")

        chartData.minXValue = chartConfiguration.modifyMinXValue(chartData.minXValue)
        os_log("Set min X value to: \(chartData.minXValue)")

        chartData.maxXValue = chartConfiguration.modifyMaxXValue(chartData.maxXValue)
        os_log("Set max X value to: \(chartData.maxXValue)")

        chartData.numberOfXSections = chartConfiguration.calculateNumberOfXSections(chartData.minXValue, chartData.maxXValue)
        os_log("Number of xSections: \(chartData.numberOfXSections)")

        let numberOfDays = chartData.maxXValue.days(from: chartData.minXValue)
        os_log("Number of days in chart: \(numberOfDays)")
        os_log("Number of points: \(chartData.points.count)")

        if let chartWidth = chartConfiguration.chartWidth {
            os_log("Chart has available width: \(chartWidth)")
            chartData.chartWidth = chartWidth - ChartConstants.yAxisLabelWidth

            if chartConfiguration.drawingOptions.drawCirclesOnPoints {
                chartData.chartWidth -= ChartConstants.circleRadius * 2
                os_log("Chart is drawing circles on points with radius: \(ChartConstants.circleRadius)")

                chartData.yOffset = ChartConstants.circleRadius
                chartData.xOffset = ChartConstants.circleRadius
                os_log("Chart xOffset: \(chartData.xOffset)")
                os_log("Chart yOffset: \(chartData.yOffset)")
            }

            chartData.xPixelsPerUnit = chartData.chartWidth / CGFloat(numberOfDays)
        } else {
            os_log("Chart is using dynamic width")
            chartData.xPixelsPerUnit = ChartConstants.xPixelsPerUnit
            chartData.chartWidth = CGFloat(numberOfDays) * chartData.xPixelsPerUnit
        }

        os_log("Chart width: \(chartData.chartWidth)")
        os_log("xPixelsPerUnit: \(chartData.xPixelsPerUnit)")

        // Normalize data points
        chartData.points = chartData.points.map { chartPoint in
            ChartPoint(
                date: chartPoint.date,
                value: chartPoint.value,
                xValue: numberOfDays - chartData.maxXValue.days(from: chartPoint.date),
                yValue: chartPoint.value - chartData.minYValue)
        }

        os_log("Chart points:")
        chartData.points.forEach { chartPoint in
            os_log("\(chartPoint)")
        }

        os_log("Min Y value: \(chartData.minYValue)")
        os_log("Max Y value: \(chartData.maxYValue)")

        chartData.yDifference = CGFloat(chartData.maxYValue - chartData.minYValue)
        os_log("yDifference: \(chartData.yDifference)")

        if chartData.yDifference == .zero {
            os_log("yDifference is undefined, setting to one")
            chartData.yDifference = 1
        }

        return chartData
    }

    private static func makeYAxisData(chartData: ChartData) -> YAxisData {
        let yAxisData = YAxisData(numberOfSections: ChartConstants.numberOfYAxisSections)
        let yUnitsPerSection = ((chartData.maxYValue - chartData.minYValue) / yAxisData.numberOfSections)

        (0...yAxisData.numberOfSections).reversed().forEach { section in
            let yValue = chartData.minYValue + (yUnitsPerSection * section)
            yAxisData.labels.append(yValue.abbreviatedString)
        }

        return yAxisData
    }

    private static func makeXAxisData(chartData: ChartData, chartConfiguration: ChartConfiguration<CovidProvider>) -> XAxisData {
        let xAxisData = XAxisData(pixelsPerUnit: chartData.xPixelsPerUnit)
        var previousUnits = 0

        // Draw line on very left of chart
        xAxisData.addLine(for: 0)

        let referenceDate = chartData.maxXValue
        let xSectionRange = chartConfiguration.xSectionRange(chartData.numberOfXSections)

        // Number of sections = 10 --> 0..9  reversed: 9-->0
        xSectionRange.reversed().forEach { xSectionIndex in
            guard let date = Calendar.current.date(byAdding: chartConfiguration.xSectionCalendarComponent, value: -xSectionIndex, to: referenceDate) else {
                fatalError("Unable to create date for xAxis section")
            }

            let units = chartConfiguration.unitsInSection(chartData.numberOfXSections, xSectionIndex, date)

            xAxisData.addLine(for: units)

            os_log("Index: \(xSectionIndex) XAxis date: \(date), units: \(units)")

            let formattedDate = chartConfiguration.dateFormatter.string(from: date)

            if xSectionIndex == chartData.numberOfXSections - 1 {
                // First section for chart starts at point zero
                xAxisData.addLabel(formattedDate, at: 0)
            } else {
                // Other sections position is the position of the units for the previous section
                xAxisData.addLabel(formattedDate, at: previousUnits)
            }

            previousUnits = units
        }

        return xAxisData
    }
}

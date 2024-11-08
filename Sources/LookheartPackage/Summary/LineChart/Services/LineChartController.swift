//
//  File.swift
//  
//
//  Created by KHJ on 10/29/24.
//

import Foundation
import DGCharts
import UIKit

class LineChartController {
    private let dateTime: MyDateTime
    
    init (dateTime: MyDateTime) {
        self.dateTime = dateTime
    }
    
    func setLineChart(
        lineChart: LineChartView,
        noDataText: String = "",
        fontSize: CGFloat = 15,
        weight: UIFont.Weight = .bold,
        granularity: Double = 1,
        labelPosition: XAxis.LabelPosition = .bottom,
        xAxisEnabled: Bool = true,
        drawGridLinesEnabled: Bool = false,
        rightAxisEnabled: Bool = false,
        dragEnabled: Bool = true,
        drawMarkers: Bool = false,
        pinchZoomEnabled: Bool = false,
        doubleTapToZoomEnabled: Bool = false,
        highlightPerTapEnabled: Bool = false
    ) {
        lineChart.do {
            $0.noDataText = noDataText
            $0.xAxis.enabled = xAxisEnabled
            $0.legend.font = .systemFont(ofSize: fontSize, weight: weight)
            $0.xAxis.granularity = granularity
            $0.xAxis.labelPosition = labelPosition
            $0.xAxis.drawGridLinesEnabled = drawGridLinesEnabled
            $0.rightAxis.enabled = rightAxisEnabled
            $0.drawMarkers = drawMarkers
            $0.dragEnabled = dragEnabled
            $0.pinchZoomEnabled = pinchZoomEnabled
            $0.doubleTapToZoomEnabled = doubleTapToZoomEnabled
            $0.highlightPerTapEnabled = highlightPerTapEnabled
        }
    }
    
    
    func getLineChartDataSet(
        entries: [String : [ChartDataEntry]],
        chartType: LineChartType,
        dateType: LineChartDateType
    ) -> [LineChartDataSet] {
        var chartDataSets: [LineChartDataSet] = []
        
        let graphColor = getGraphColor(chartType, dateType)
        let sortedKeys = getSortedKeys(entries, chartType)
        
        for (graphIdx, key) in sortedKeys.enumerated() {
            guard let entry = entries[key] else { continue }
            
            let label = getLabel(key, chartType)
            let chartDataSet = LineChartDataSet(entries: entry, label: label)
            
            setLineChartDataSet(chartDataSet, graphColor[graphIdx], chartType)
            
            chartDataSets.append(chartDataSet)
        }

        return chartDataSets
    }

    
    private func getSortedKeys(
        _ entries: [String : [ChartDataEntry]],
        _ chartType: LineChartType
    ) -> [String] {
        switch chartType {
            
        case .BPM, .HRV:
            return entries.keys.sorted()
        case .STRESS:
            return ["sns", "pns"]
        }
    }
    
    private func getLabel(
        _ key: String,
        _ chartType: LineChartType
    ) -> String {
        switch chartType {
        case .BPM, .HRV:
            return dateTime.changeDateFormat(key, false)
        case .STRESS:
            return key
        }
    }
    
    private func getColor(for date: String, from colors: [UIColor]) -> UIColor? {
        guard !colors.isEmpty else { return nil }
        let hash = date.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    private func setLineChartDataSet(
        _ chartDataSet: LineChartDataSet,
        _ color: NSUIColor,
        _ type: LineChartType
    ) {
        let lineWidth = type != .STRESS ? 0.7 : 1.2
        
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(color)
        chartDataSet.mode = .linear
        chartDataSet.lineWidth = lineWidth
        chartDataSet.drawValuesEnabled = true
    }
    
    private func sortedDictionary(_ dateChartDict: [String : LineChartDataSet]) -> [LineChartDataSet] {
        var chartDataSets: [LineChartDataSet] = []
        
        let sortedDates = dateChartDict.keys.sorted()
        
        for date in sortedDates {
            if let chartDataSet = dateChartDict[date] {
                chartDataSets.append(chartDataSet)
            }
        }
        
        return chartDataSets
    }
    
    func showChart(
        lineChart: LineChartView,
        chartData: LineChartData,
        timeTable: [String],
        chartType: LineChartType
    ) {
        let maximum = getChartMaximum(chartType)
        let axisMaximum = getChartAxisMaximum(chartType)
        let axisMinimum = getChartAxisMinimum(chartType)
        let removeSecondTimeTable = removeSecond(timeTable)
        
        addLimitLine(lineChart, chartType)
        
        lineChart.data = chartData
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: removeSecondTimeTable)
        lineChart.setVisibleXRangeMaximum(maximum)
        lineChart.leftAxis.axisMaximum = axisMaximum
        lineChart.leftAxis.axisMinimum = axisMinimum
        
        lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        lineChart.moveViewToX(0)
        
        chartZoomOut(lineChart)
    }
    
    func showChart(
        lineChart: LineChartView,
        lineChartModel: LineChartModel
    ) -> Bool {
        // 1. entries
        guard let entries = lineChartModel.entries else {
            return false // noData
        }
        
        // 2. chart data sets
        let chartDataSets = getLineChartDataSet(
            entries: entries,
            chartType: lineChartModel.chartType,
            dateType: lineChartModel.dateType
        )
        
        // 3. line chart data
        let lineChartData = LineChartData(dataSets: chartDataSets)
        
        // 4. set line chart
        addLimitLine(lineChart, lineChartModel.chartType, lineChartModel)
        
        let maximum = getChartMaximum(lineChartModel.chartType)
        let axisMaximum = getChartAxisMaximum(lineChartModel.chartType)
        let axisMinimum = getChartAxisMinimum(lineChartModel.chartType)
        let removeSecondTimeTable = removeSecond(lineChartModel.timeTable)
        
        lineChart.data = lineChartData
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: removeSecondTimeTable)
        lineChart.setVisibleXRangeMaximum(maximum)
        lineChart.leftAxis.axisMaximum = axisMaximum
        lineChart.leftAxis.axisMinimum = axisMinimum
        
        // 5. show chart
        lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        lineChart.moveViewToX(0)
        
        chartZoomOut(lineChart)
        
        return true
    }
    
    private func removeSecond(_ timeTable: [String]) -> [String] {
        return timeTable.map { String($0.dropLast(3)) }
    }
    
    private func addLimitLine(
        _ lineChart: LineChartView,
        _ chartType: LineChartType,
        _ model: LineChartModel? = nil
    ) {
        lineChart.leftAxis.removeAllLimitLines()
        
        switch chartType {
        case .BPM, .HRV:
            guard let model else { return }
            
            let topLimitLine = model.avgValue + model.standardDeviationValue
            let bottomLimitLine = model.avgValue - model.standardDeviationValue
            
            addLimitLine(to: lineChart, limit: model.avgValue, label: "unit_avg_cap".localized(), color: NSUIColor.MY_ORANGE)
            addLimitLine(to: lineChart, limit: topLimitLine, label: "unit_standard_deviation".localized(), color: NSUIColor.MY_PINK)
            addLimitLine(to: lineChart, limit: bottomLimitLine, label: "unit_standard_deviation".localized(), color: NSUIColor.MY_PINK)
        case .STRESS:
            addLimitLine(to: lineChart, limit: 60, label: "", color: NSUIColor.MY_SKY)
            addLimitLine(to: lineChart, limit: 40, label: "", color: NSUIColor.MY_SKY)
            addLimitLine(to: lineChart, limit: 80, label: "", color: NSUIColor.MY_LIGHT_PINK)
            addLimitLine(to: lineChart, limit: 20, label: "", color: NSUIColor.MY_LIGHT_PINK)
        }
    }
    
    private func addLimitLine(
        to lineChart: LineChartView,
        limit: Double,
        label: String,
        color: UIColor,
        width: CGFloat = 2.0,
        dashLengths: [CGFloat] = [3.0, 2.0, 0.0]    // length, space, offset
    ) {
        let limitLine = ChartLimitLine(limit: limit, label: label)
        
        limitLine.lineWidth = width
        limitLine.lineColor = color
        limitLine.lineDashLengths = dashLengths
        limitLine.labelPosition = .rightTop
        limitLine.valueFont = UIFont.boldSystemFont(ofSize: 10)
        limitLine.valueTextColor = color
        
        lineChart.leftAxis.addLimitLine(limitLine)
    }
    
    private func getChartMaximum(_ chartType: LineChartType) -> Double {
        switch chartType {
        case .BPM, .HRV, .STRESS:
            return 1000
        }
    }
    
    private func getChartAxisMaximum(_ chartType: LineChartType) -> Double {
        switch chartType {
        case .BPM, .HRV:
            return 200
        case .STRESS:
            return 100
        }
    }
    
    private func getChartAxisMinimum(_ chartType: LineChartType) -> Double {
        switch chartType {
        case .BPM:
            return 40
        case .HRV, .STRESS:
            return 0
        }
    }
    
    private func chartZoomOut(_ lineChart: LineChartView) {
        for _ in 0..<20 {
            lineChart.zoomOut()
        }
    }
    
    private func getGraphColor(
        _ chartType: LineChartType,
        _ dateType: LineChartDateType
    ) -> [UIColor] {
        switch chartType {
        case .BPM, .HRV:
            switch (dateType) {
            case .TODAY:
                return [NSUIColor.MY_RED]
            case .TWO_DAYS:
                return [NSUIColor.MY_RED, NSUIColor.GRAPH_BLUE]
            case .THREE_DAYS:
                return [NSUIColor.MY_RED, NSUIColor.GRAPH_BLUE, NSUIColor.GRAPH_GREEN]
            }
            
        case .STRESS:
            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
        }
    }
}

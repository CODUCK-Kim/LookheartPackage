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
    
//    func getLineChartDataSet(
//        entries: [String : [ChartDataEntry]],
//        chartType: LineChartType,
//        dateType: LineChartDateType
//    ) -> [LineChartDataSet] {
//        let graphColor = getGraphColor(chartType, dateType)
//        var graphIdx = 0
//            
//        var dateChartDict: [String : LineChartDataSet] = [:]
//        
//        for (date, entry) in entries {
//            let label = getLabel(date, chartType)
//            let chartDataSet = LineChartDataSet(entries: entry, label: label)
//            
//            setLineChartDataSet(chartDataSet, graphColor[graphIdx], chartType)
//            
//            dateChartDict[date] = chartDataSet
//            graphIdx += 1
//        }
//        
//        return sortedDictionary(dateChartDict)
//    }
    
    func getLineChartDataSet(
        entries: [String : [ChartDataEntry]],
        chartType: LineChartType,
        dateType: LineChartDateType
    ) -> [LineChartDataSet] {
        let graphColor = getGraphColor(chartType, dateType)
        
        var dateChartDict: [String : LineChartDataSet] = [:]
        
        for (date, entry) in entries {
            let label = getLabel(date, chartType)
            let chartDataSet = LineChartDataSet(entries: entry, label: label)
            
            // 날짜 기반으로 색상 매핑
            if let color = getColor(for: date, from: graphColor) {
                setLineChartDataSet(chartDataSet, color, chartType)
            } else {
                // 기본 색상 설정 (필요시)
                setLineChartDataSet(chartDataSet, NSUIColor.gray, chartType)
            }
            
            dateChartDict[date] = chartDataSet
        }
        
        let sortedDict = sortedDictionary(dateChartDict)
        
        return Array(sortedDict)
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
        let lineWidth = type != .STRESS ? 1.0 : 0.7
        
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
        
        lineChart.data = chartData
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: timeTable)
        lineChart.setVisibleXRangeMaximum(maximum)
        lineChart.leftAxis.axisMaximum = axisMaximum
        lineChart.leftAxis.axisMinimum = axisMinimum
        
        lineChart.data?.notifyDataChanged()
        lineChart.notifyDataSetChanged()
        lineChart.moveViewToX(0)
        
        chartZoomOut(lineChart)
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
                return [NSUIColor.GRAPH_RED]
            case .TWO_DAYS:
                return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
            case .THREE_DAYS:
                return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE, NSUIColor.GRAPH_GREEN]
            }
            
        case .STRESS:
            return [NSUIColor.GRAPH_RED, NSUIColor.GRAPH_BLUE]
        }
    }
}

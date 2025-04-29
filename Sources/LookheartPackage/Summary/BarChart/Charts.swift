import Foundation
import DGCharts


class CombinedValueFormatter: ValueFormatter {
    // 0이 아닌 정수 값만 표시
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard value != 0 else { return "" } // 값이 0이면 빈 문자열 반환
        return String(format: "%.0f", value) // 그렇지 않으면 정수 형태로 값 반환
    }
}

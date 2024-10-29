import Foundation
import DGCharts

struct LineChartModel {
    var entries: [String : [ChartDataEntry]]?
    var dictData: [String: [String: LineChartDataModel]]
    var timeTable: [String]
    var type: LineChartType
}

struct LineChartDataModel {
    var idx: String
    var eq: String
    var writeDateTime: String
    var writeDate: String
    var writeTime: String
    var timezone: String
    
    // bpm, hrv
    var bpm: Double?
    var temp: Double?
    var hrv: Double?
    
    // stress
    var pns: Double?
    var sns: Double?
    var stress: Double?
    
    static func changeFormat(datalist: [Substring]) -> [LineChartDataModel] {
        var parsedRecords = [LineChartDataModel]()
        
        for data in datalist {
            let fields = data.split(separator: "|")
            
            if fields.count == 7 {
                guard let bpm = Int(fields[4]),
                      let temp = Double(fields[5]),
                      let hrv = Int(fields[6]) else {
                    continue
                }
                
                let dateTime = fields[2].split(separator: " ")
                
                parsedRecords.append( LineChartDataModel(
                    idx: String(fields[0]),
                    eq: String(fields[1]),
                    writeDateTime: String(fields[2]),
                    writeDate: String(dateTime[0]),
                    writeTime: String(dateTime[1]),
                    timezone: String(fields[3]),
                    bpm: Double(bpm),
                    temp: Double(temp),
                    hrv: Double(hrv)
                ))
            }
        }
        
        return parsedRecords
    }
}

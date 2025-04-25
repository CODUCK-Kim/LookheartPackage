import Foundation
import DGCharts

struct LineChartModel {
    var entries: [String : [ChartDataEntry]]?
    var dictData: [String: [String: LineChartDataModel]]
    var timeTable: [String]
    var chartType: LineChartType
    var dateType: LineChartDateType
    
    var stats: ChartStatistics? = nil
    var stressStats: StressChartStatistics? = nil
    var standardDeviationValue: Double? = nil
}

struct StressDataModel: Codable {
    let writeTime: String
    let pnsPercent: Double
    let snsPercent: Double
    
    enum CodingKeys: String, CodingKey {
        case writeTime = "writetime"
        case pnsPercent = "pns_percent"
        case snsPercent = "sns_percent"
    }
}

struct LineChartDataModel {
    var idx: String?
    var eq: String?
    var writeDateTime: String
    var writeDate: String
    var writeTime: String
    var timezone: String?
    
    // bpm, hrv
    var bpm: Double?
    var temp: Double?
    var hrv: Double?
    
    // stress
    var pns: Double?
    var sns: Double?
    var stress: Double?
    
    // bpm, hrv
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
                
                if let localDateTime = DateTimeManager.shared.convertUtcToLocal(utcTimeStr: String(fields[2])) {
                    let dateTime = localDateTime.split(separator: " ")
                    
                    parsedRecords.append(
                        LineChartDataModel(
                            idx: String(fields[0]),
                            eq: String(fields[1]),
                            writeDateTime: localDateTime,
                            writeDate: String(dateTime[0]),
                            writeTime: String(dateTime[1]),
                            timezone: String(fields[3]),
                            bpm: Double(bpm),
                            temp: Double(temp),
                            hrv: Double(hrv)
                        )
                    )
                    
                }
            }
        }
        
        return parsedRecords
    }
    
    // Stress
    static func changeFormat(stressData: [StressDataModel]) -> [LineChartDataModel] {
        var parsedRecords = [LineChartDataModel]()
        
        
        for data in stressData {
            if data.pnsPercent == 100.0 || data.snsPercent == 100.0 {
                continue
            }
            
            let splitDateTime = data.writeTime.split(separator: " ")
                        
            parsedRecords.append( LineChartDataModel(
                writeDateTime: data.writeTime,
                writeDate: String(splitDateTime.first ?? ""),
                writeTime: String(splitDateTime.last ?? ""),
                pns: data.pnsPercent,
                sns: data.snsPercent
            ))
        }
        return parsedRecords
    }
}

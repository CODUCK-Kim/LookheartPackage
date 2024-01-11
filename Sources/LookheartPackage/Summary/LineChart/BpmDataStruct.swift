import Foundation

struct BpmData {
    var idx: String
    var eq: String
    var writetime: String
    var timezone: String
    var bpm: String
    var temp: String
    var hrv: String
}

class BpmDataController {
    
    public static let shared = BpmDataController()
    
    private var bpmDataList: [String: [BpmData]] = [:]
    
    public func setData(_ date: String, _ bpmData: [BpmData]) {
        bpmDataList[date] = bpmData
    }
    
    public func getList() -> [String: [BpmData]] {
        return bpmDataList
    }
    
    public func getData(_ date: String) -> [BpmData]? {
        return bpmDataList[date] ?? nil
    }
    
    public func addData(_ key: String, _ value: BpmData) {
        bpmDataList[key]?.append(value)
    }
    
    public func removeAllData() {
        bpmDataList.removeAll()
    }
}

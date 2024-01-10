import Foundation

struct ArrData: Equatable {
    var idx: String
    var writeTime: String
    var time: String
    var timezone: String
    var bodyStatus: String
    var type: String
    var preEcgData: [Double]
    var data: [Double]
}

struct EcgData: Codable {
    let ecg: String?
    let arr: String
}

struct ArrDateEntry: Decodable {
    let writetime: String
    let address: String?
}

struct ArrEcgData: Decodable {
    let ecgpacket: String
}

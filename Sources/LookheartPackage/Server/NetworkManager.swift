import Foundation
import Alamofire

public class NetworkManager {
    
    private let baseURL = "http://121.152.22.85:40081" // TEST
//    private let baseURL = "http://121.152.22.85:40080" // REAL
    
    public static let shared = NetworkManager()

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
            
    public func sendEmergencyData(_ identification: String, _ timezone: String,_ address: String) {
    
        let endpoint = "/mslecgarr/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let currentDateTime = NetworkManager.dateFormatter.string(from: Date())
        
        let params: [String: Any] = [
            "kind": "arrEcgInsert",
            "eq": identification,
            "timezone": timezone,
            "writetime": currentDateTime,
            "ecgPacket": "",
            "arrStatus": "",
            "bodystate": "1",
            "address": address
        ]
        
        request(url: url, method: .post, parameters: params) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Emergency Received response: \(responseString)")
                }
            case .failure(let error):
                print("send EmergencyData Send Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    public func getProfileToServer(id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        let endpoint = "/msl/Profile"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "empid": id
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                
                    let decoder = JSONDecoder()
                    let userProfiles = try decoder.decode([UserProfile].self, from: data) // 디코딩
                    
                    var phoneNumbers: [String] = []
                    
                    for _ in userProfiles { // 프로필이 여러개 있을 경우 보호자 핸드폰 번호 저장
                        phoneNumbers.append(UserProfileManager.shared.getPhoneNumber())
                    }
                    
                    // 첫 번째 프로필을 기본 프로필로 설정하고, 핸드폰 번호 목록을 저장
                    if let primaryProfile = userProfiles.first {
                        UserProfileManager.shared.setPhoneNumbers(phoneNumbers)
                        completion(.success(primaryProfile))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                    
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    public func setGuardianToServer(id: String, timezone: String, phone:[String],  completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let endpoint = "/mslparents/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let currentDateTime = NetworkManager.dateFormatter.string(from: Date())
        let parameters: [String: Any] = [
            "eq": id,
            "timezone": timezone,
            "writetime": currentDateTime,
            "phones": phone
        ]
        
        request(url: url, method: .post, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("setGuardian Received response: \(responseString)")
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("setGuardian Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    public func checkLoginToServer(id: String, pw: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let endpoint = "/msl/CheckLogin"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "empid": id,
            "pw": pw
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("checkID Received response: \(responseString)")
                    
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    public func checkIDToServer(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let endpoint = "/msl/CheckIDDupe"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "empid": id
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("checkID Received response: \(responseString)")
                    
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    
    

    
    
    
    
    
    
    public func signupToServer(parameters: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let endpoint = "/msl/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        request(url: url, method: .post, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("setProfileToServer: \(responseString)")
                    
                    if responseString.contains("true"){
                        completion(.success(true))
                    } else if responseString.contains("false"){
                        completion(.success(false))
                    } else {
                        completion(.failure(NetworkError.invalidResponse)) // 예상치 못한 응답
                    }
                    
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
                
            case .failure(let error):
                print("signupToServer Send Error : \(error.localizedDescription)")
            }
        }
    }
    

    
    
    
    
    
    
    
    public func sendEcgDataToServer(packet: String, identification: String, bpm: Int, timezone: String, writeTime: String) {
        
        let endpoint = "/mslecg/api_getdata"
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "kind": "ecgdataInsert",
            "eq": identification,
            "writetime": writeTime,
            "ecgtimezone": timezone,
            "bpm": bpm,
            "ecgPacket": packet
        ]
        
        request(url: url, method: .post, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if String(data: data, encoding: .utf8) != nil {
//                    print("EcgData Received response: \(responseString)")
                }
            case .failure(let error):
                print("sendEcgDataToServer Send Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    public func sendByteEcgDataToServer(ecgData: [Int], bpm: Int, writeDateTime: String) {
        
        let identification = UserProfileManager.shared.getEmail()
        let timeZone = MyDateTime.shared.getTimeZone()
        
        let endpoint = "/mslecgbyte/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }

        let parameters: [String: Any] = [
            "kind": "ecgByteInsert",
            "eq": identification,
            "writetime": writeDateTime,
            "timezone": timeZone,
            "bpm": bpm,
            "ecgPacket": ecgData
        ]
        
        request(url: url, method: .post, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if String(data: data, encoding: .utf8) != nil {
//                    print("EcgData Received response: \(responseString)")
                }
            case .failure(let error):
                print("sendEcgDataToServer Send Error : \(error.localizedDescription)")
            }
        }
    }
    
    public func sendTenSecondDataToServer(tenSecondData: [String: Any], writeDateTime: String) {
        
        let identification = UserProfileManager.shared.getEmail()
        let timeZone = MyDateTime.shared.getTimeZone()
        
        let endpoint = "/mslbpm/api_data"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        var params: [String: Any] = [
            "kind": "BpmDataInsert",
            "eq": identification,
            "timezone": timeZone,
            "writetime": writeDateTime
        ]
        
        params.merge(tenSecondData) { (current, _) in current }
                
        request(url: url, method: .post, parameters: params) { result in
            switch result {
            case .success(let data):
                if String(data: data, encoding: .utf8) != nil {
//                    print("TenSecondData Received response: \(responseString)")
                }
            case .failure(let error):
                print("sendTenSecondDataToServer Send Error : \(error.localizedDescription)")
            }
        }
    }
 
    public func sendHourlyDataToServer(_ year: String, _ month: String, _ day: String, _ identification: String,  _ utcOffsetAndCountry: String, _ data: String) {
        
        let endpoint = "/mslecgday/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let dataArray = data.split(separator: ",").map { String($0) }
        let dataHour = dataArray[0]
        let hourlyStep = dataArray[2]
        let hourlyDistance = dataArray[3]
        let hourlyCal = dataArray[4]
        let hourlyECal = dataArray[5]
        let hourlyArrCnt = dataArray[6]
        
        let params: [String: Any] = [
            "kind": "calandInsert",
            "eq": identification,
            "datayear": year,
            "datamonth": month,
            "dataday": day,
            "datahour": dataHour,
            "ecgtimezone": utcOffsetAndCountry,
            "step": hourlyStep,
            "distanceKM": hourlyDistance,
            "cal": hourlyCal,
            "calexe": hourlyECal,
            "arrcnt": hourlyArrCnt
        ]
        
        request(url: url, method: .post, parameters: params) { result in
            switch result {
            case .success(let data):
                if let _ = String(data: data, encoding: .utf8) {
//                    print("HourlyData Received response: \(responseString)")
                }
            case .failure(let error):
                print("sendHourlyDataToServer Send Error: \(error.localizedDescription)")
            }
        }
    }
        
    public func sendArrDataToServer(_ bodyStatus: String, _ arrStatus: String,_ arrEcgData: String, _ writeTime: String, _ writeDateTime: String) {
    
        let identification = UserProfileManager.shared.getEmail()
        let timeZone = MyDateTime.shared.getTimeZone()
        
        let arrData = "\(writeTime),\(timeZone),\(bodyStatus),\(arrStatus),\(arrEcgData)"
        
        let endpoint = "/mslecgarr/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let params: [String: Any] = [
            "kind": "arrEcgInsert",
            "eq": identification,
            "writetime": writeDateTime,
            "ecgPacket": arrData
        ]
        
        request(url: url, method: .post, parameters: params) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    print("ArrData Received response: \(responseString)")
                }
            case .failure(let error):
                print("sendArrDataToServer Send Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getBpmDataToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[BpmData], Error>) -> Void) {

        var bpmData: [BpmData] = []
        let endpoint = "/mslbpm/api_getdata"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]

        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    if !(responseString.contains("result = 0")) {
                        let newlineData = responseString.split(separator: "\n")
                        let splitData = newlineData[1].split(separator: "\r\n")
                        for data in splitData {
                            let fields = data.split(separator: "|")
                            
                            if fields.count == 7 {
                                if let bpm = Int(fields[4]), 
                                    let temp = Double(fields[5]),
                                    let hrv = Int(fields[6]) {
                                    let dateTime = fields[2].split(separator: " ")
                                    
                                    bpmData.append( BpmData(
                                        idx: String(fields[0]),
                                        eq: String(fields[1]), 
                                        writeDateTime: String(fields[2]),
                                        writeDate: String(dateTime[0]),
                                        writeTime: String(dateTime[1]),
                                        timezone: String(fields[3]),
                                        bpm: String(bpm),
                                        temp: String(temp),
                                        hrv: String(hrv)
                                    ))
                                }
                            }
                        }
                        
                        completion(.success(bpmData))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func getHourlyDataToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[HourlyData], Error>) -> Void) {
                
        var hourlyData: [HourlyData] = []
        let endpoint = "/mslecgday/day"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        // ex)
        // eq(0) : jhaseung@medsyslab.co.kr
        // date(1) : 2024-01-15 05:00:00
        // timeZone(2) : +09:00/Asia/Seoul/KR
        // year(3) : 2024
        // month(4) : 1
        // day(5) : 15
        // hour(6) : 9
        // data(7 ~ 11) : 1984|1495|307|98|9
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                if let responseString = String(data: data, encoding: .utf8) {
                    if !(responseString.contains("result = 0")) {

                        let newlineData = responseString.split(separator: "\n")
                        let splitData = newlineData[1].split(separator: "\r\n")

                        for data in splitData {
                            let fields = data.split(separator: "|")

                            if fields.count == 12 {
                                if let step = Int(fields[7]), let distance = Int(fields[8]), let cal = Int(fields[9]), let activityCal = Int(fields[10]), let arrCnt = Int(fields[11]) {
                                    let record = HourlyData(
                                        eq: String(fields[0]),
                                        timezone: String(fields[2]),
                                        
                                        date: String(fields[1].split(separator: " ")[0]),
                                        year: String(fields[3]),
                                        month: String(fields[4]),
                                        day: String(fields[5]),
                                        hour: String(fields[6]),
                                        
                                        step: String(step),
                                        distance: String(distance),
                                        cal: String(cal),
                                        activityCal: String(activityCal),
                                        arrCnt: String(arrCnt)
                                    )
                                    
                                    hourlyData.append(record)
                                }
                            }
                        }
                        
                        completion(.success(hourlyData))
                        
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                    
                } else {
                    completion(.failure(NetworkError.invalidResponse)) // 데이터 디코딩 실패
                }
            case .failure(let error):
                print("checkID Server Request Error : \(error.localizedDescription)")
            }
        }
    }
    
    
    public func getArrListToServer(id: String, startDate: String, endDate: String, completion: @escaping (Result<[ArrDateEntry], Error>) -> Void) {
        
        let endpoint = "/mslecgarr/arrWritetime?"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": endDate
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let result = String(data: data, encoding: .utf8)
                    if !(result!.contains("result = 0")) {
                        completion(.success(try JSONDecoder().decode([ArrDateEntry].self, from: data)))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                print("getArrListToServer Request Error : \(error.localizedDescription)")
            }
        }
    }
    
//    func selectArrDataToServer(id: String, startDate: String, completion: @escaping (Result<ArrData, Error>) -> Void) {
//
//        let endpoint = "/mslecgarr/arrWritetime?"
//        guard let url = URL(string: baseURL + endpoint) else {
//            print("Invalid URL")
//            return
//        }
//
//        let parameters: [String: Any] = [
//            "eq": id,
//            "startDate": startDate,
//            "endDate": ""
//        ]
//
//        request(url: url, method: .get, parameters: parameters) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let arrData = try JSONDecoder().decode([ArrEcgData].self, from: data)
//                    let resultString = arrData[0].ecgpacket.split(separator: ",")
//
//                    if resultString.count > 500 {
//                        let ecgData = resultString[4...].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
//
//                        completion(.success(ArrData.init(
//                            idx: "0",
//                            writeTime: "0",
//                            time: self.removeWsAndNl(resultString[0]),
//                            timezone: "0",
//                            bodyStatus: self.removeWsAndNl(resultString[2]),
//                            type: self.removeWsAndNl(resultString[3]),
//                            data: ecgData)))
//                    } else {
//                        completion(.success(ArrData.init(
//                            idx: "",
//                            writeTime: "",
//                            time: "",
//                            timezone: "",
//                            bodyStatus: "응급 상황",
//                            type: "응급 상황",
//                            data: [])))
//                    }
//
//                } catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//                print("checkID Server Request Error : \(error.localizedDescription)")
//            }
//        }
//    }
    
    public func selectArrDataToServer(id: String, startDate: String, completion: @escaping (Result<ArrData, Error>) -> Void) {
        
        let endpoint = "/mslecgarr/arrWritetime?"
        guard let url = URL(string: baseURL + endpoint) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "eq": id,
            "startDate": startDate,
            "endDate": ""
        ]
        
        request(url: url, method: .get, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let arrData = try JSONDecoder().decode([ArrEcgData].self, from: data)
                    let resultString = arrData[0].ecgpacket.split(separator: ",")

                    if resultString.count > 500 {
                        let ecgData = resultString[4...].compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

                        completion(.success(ArrData.init(
                            idx: "0",
                            writeTime: "0",
                            time: self.removeWsAndNl(resultString[0]),
                            timezone: "0",
                            bodyStatus: self.removeWsAndNl(resultString[2]),
                            type: self.removeWsAndNl(resultString[3]),
                            data: ecgData)))
                    } else {
                        completion(.success(ArrData.init(
                            idx: "",
                            writeTime: "",
                            time: "",
                            timezone: "",
                            bodyStatus: "응급 상황",
                            type: "응급 상황",
                            data: [])))
                    }
                } catch {
                    print("arrData 변환 Error : \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("selectArrDataToServer Request Error : \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func getEcgArray(_ ecgData: String) -> [Double] {
        let formattedStr = ecgData
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "][", with: ",")
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
        return formattedStr
            .components(separatedBy: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
    private func request(url: URL, method: HTTPMethod, parameters: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        
        // Alamofire
        AF.request(url, method: method, parameters: parameters,
                   encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // Ws : whitespaces & Nl : Newlines
    private func removeWsAndNl(_ string: Substring) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

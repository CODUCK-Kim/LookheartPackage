import Alamofire
import Foundation

public class AlamofireController {
    private let baseURL = "http://db.medsyslab.co.kr:40081/" // TEST
//    private let baseURL = "http://db.medsyslab.co.kr:40080/" // REAL
    
    public static let shared = AlamofireController()
    
    public enum EndPoist: String {
        // GET: Health Data
        case getVersion = "appversion/getVersion"
        case getBpmData = "mslbpm/api_getdata"
        case getArrListData = "mslecgarr/arrWritetime?" // List, Data
        case getHourlyData = "mslecgday/day"
        
        // GET: User Data
        case getProfile = "msl/Profile"
        case getFindID = "msl/findID?"
        case getCheckLogin = "msl/CheckLogin"
        case getCheckDupID = "msl/CheckIDDupe"
        
        // GET: Auth
        case getSendSms = "mslSMS/sendSMS"
        case getCheckSMS = "mslSMS/checkSMS"
        case getCheckPhoneNumber = "msl/checkPhone?"
        case getAppKey = "msl/appKey?"
        
        
        
        // POST: HealthData
        case postTenSecondData = "mslbpm/api_data"
        case postHourlyData = "mslecgday/api_getdata"
        case postEcgData = "mslecgbyte/api_getdata"
        case postArrData = "mslecgarr/api_getdata"
        
        // POST: User
        case postSetProfile = "msl/api_getdata" // profile, appKey
        case postSetGuardian = "mslparents/api_getdata"
        
        // POST: Log
        case postLog = "app_log/api_getdata"
        case postBleLog = "app_ble/api_getdata"
    }
    
    // MARK: -
    public func alamofireController(
        parameters: [String: Any],
        endPoint: EndPoist,
        method: HTTPMethod,
        completion: @escaping (Result<String, Error>) -> Void)
    {
        guard let url = URL(string: baseURL + endPoint.rawValue) else {
            print("Invalid URL")
            return
        }
        
        request(url: url, method: method, parameters: parameters) { result in
            switch result {
            case .success(let result):
            
                print(result)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: -
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
}

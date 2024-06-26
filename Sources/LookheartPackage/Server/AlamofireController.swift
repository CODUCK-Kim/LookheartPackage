import Alamofire
import Foundation

public enum NetworkResponse {
    case successWithData(String)
    case success
    case failer
    case notConnected
    case session
    case invalidResponse
    case noData
}


public class AlamofireController {
    private lazy var baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Test URL") as? String else {
            fatalError("Base URL not found in Info.plist")
        }
        return url
    }()

    private lazy var spareURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Test Spare URL") as? String else {
            fatalError("Spare URL not found in Info.plist")
        }
        return url
    }()
    
    private lazy var mongoURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Mongo URL") as? String else {
            fatalError("Mongo URL not found in Info.plist")
        }
        return url
    }()
    
//    private lazy var baseURL: String = {
//        guard let url = Bundle.main.object(forInfoDictionaryKey: "Base URL") as? String else {
//            fatalError("Base URL not found in Info.plist")
//        }
//        return url
//    }()
//    
//    
//    private lazy var spareURL: String = {
//        guard let url = Bundle.main.object(forInfoDictionaryKey: "Spare URL") as? String else {
//            fatalError("Spare URL not found in Info.plist")
//        }
//        return url
//    }()

    
    public static let shared = AlamofireController()
    
    public enum EndPoist: String {
        // GET: Health Data
        case getVersion = "appversion/getVersion"
        case getBpmData = "mslbpm/api_getdata"
        case getBpmTime = "mslLast/lastBpmTime"
        case getArrListData = "mslecgarr/arrWritetime?" // List, Data
        case getArrCnt = "mslecgarr/arrCount?" // Cnt
        case getHourlyData = "mslecgday/day"
        
        
        // GET: User Data
        case getProfile = "msl/Profile"
        case getFindID = "msl/findID?"
        case getCheckLogin = "msl/CheckLogin"   // CheckLogin, Send Firebase Token
        case getCheckDupID = "msl/CheckIDDupe"
        
        
        // GET: Auth
        case getSendSms = "mslSMS/sendSMS"
        case getCheckSMS = "mslSMS/checkSMS"
        case getCheckPhoneNumber = "msl/checkPhone?"
        case getAppKey = "msl/appKey?"
        
        
        // GET: Exercise
        case getExerciseList = "exercise/list?"
        case getExerciseData = "exercise/data?"
        
        
        
        
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
        
        // POST: Exercise
        case postExerciseData = "exercise/create"
        case deleteExerciseData = "exercise/delete"
    }
    
    
    @available(iOS 13.0.0, *)
    public func alamofireControllerAsync <T: Decodable> (
        parameters: [String: Any],
        endPoint: EndPoist, 
        method: HTTPMethod,
        mongo: Bool = false
    ) async throws -> T {
        
        let baseUrl = mongo ? mongoURL : baseURL
        
        guard let url = URL(string: baseUrl + endPoint.rawValue) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }

        let response = try await AF.request(url, method: method, parameters: parameters, encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .serializingData().value
        
        return try JSONDecoder().decode(T.self, from: response)
    }
    
    
    
    @available(iOS 13.0.0, *)
    public func alamofireControllerForString(
        parameters: [String: Any],
        endPoint: EndPoist,
        method: HTTPMethod,
        mongo: Bool = false
    ) async throws -> String {
        
        let baseUrl = mongo ? mongoURL : baseURL
        
        guard let url = URL(string: baseUrl + endPoint.rawValue) else {
            throw NSError(domain: "InvalidURL", code: -1, userInfo: nil)
        }
            
        let response = try await AF.request(url, method: method, parameters: parameters,
                                            encoding: (method == .get) ? URLEncoding.default : URLEncoding.httpBody)
            .validate(statusCode: 200..<300)
            .serializingData().value
        
        guard let stringData = String(data: response, encoding: .utf8) else {
            throw NSError(domain: "DataEncodingError", code: -2, userInfo: nil)
        }

        return stringData
    }
    
    
    public func handleError(_ error: Error) -> NetworkResponse {
        if let error = error as? AFError {
            switch error {
            case .sessionTaskFailed(let underlyingError):
                if let urlError = underlyingError as? URLError, urlError.code == .notConnectedToInternet {
                    return .notConnected
                } else {
                    changeURL()
                    return .session
                }
            default:
                return .invalidResponse
            }
        } else {
            return .invalidResponse
        }
    }
    
    public func changeURL() {
        if baseURL != spareURL {
            swap(&baseURL, &spareURL)
        }
    }
}

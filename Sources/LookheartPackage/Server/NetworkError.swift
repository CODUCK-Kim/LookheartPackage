import Foundation


enum NetworkError: Error {
    case invalidResponse
    case noData
}

public class NetworkErrorManager {
    
    static let shared = NetworkErrorManager()
    
    func getErrorMessage(_ error: NetworkError) -> String {
        switch (error) {
            
        case .invalidResponse:
            return "serverErr".localized()
        case .noData:
            return "noData".localized()
        }
    }
    
}

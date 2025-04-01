import Alamofire
import Foundation
import Moya



// 定义Moya的Service
enum APIService {
    case fetchStudyTools
    case fetchUserProfile
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "https://fakestoreapi.com")!
    }

    var path: String {
        switch self {
        case .fetchStudyTools:
            return "/products"
        case .fetchUserProfile:
            return "/users/1"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchStudyTools, .fetchUserProfile:
            return .get
        }
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

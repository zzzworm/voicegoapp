import Alamofire
import Foundation
import Moya



// 定义Moya的Service
enum APIService {
    case fetchStudyTools
    case fetchUserProfile
    
    case loginLocal(LoginEmailRequest)
    case registerLocal(RegisterEmailRequest)
    
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: Configuration.current.baseURL)!
    }

    var path: String {
        switch self {
        case .fetchStudyTools:
            return "/api/study-tools"
        case .fetchUserProfile:
            return "/api/users/me"
        case .loginLocal:
            return "/api/auth/local"
        case .registerLocal:
            return "/api/auth/local/register"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchStudyTools, .fetchUserProfile:
            return .get
        case .loginLocal, .registerLocal:
            return .post
        }
    }

    var task: Task {
        switch self {
        case  .registerLocal(let request):
            let parameters = try! DictionaryEncoder().encode(request)
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .loginLocal(let request) :
            let parameters = try! DictionaryEncoder().encode(request)
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        default:
            return .requestPlain
        }
    }

    static let defaultHeaders: [String: String] = {
        var headers = [String: String]()
        headers["X-API-VERSION"] = Configuration.current.apiVersion
        headers["X-OS-TYPE"] = Configuration.current.osName
        headers["X-TIMEZONE-OFFSET"] = Configuration.current.timezoneOffset
        return headers
    }()
    
    var headers: [String: String]? {
        switch self {
        default:
            return APIService.defaultHeaders
        }
    }
}


// MARK - AccessTokenAuthorizable

extension APIService: AccessTokenAuthorizable {
    
    public var authorizationType: AuthorizationType? {
        switch self {
        case .loginLocal, .registerLocal:
            return .none

        default:
            return .bearer
        }
    }
}

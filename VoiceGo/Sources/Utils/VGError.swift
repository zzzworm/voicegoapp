import Foundation

public enum VGError: LocalizedError {
  public enum NetworkReason {
    case invalidURL
    case invalidResponse
    case invalidURLHTTPResponse(Int? = nil)
    case `default`
  }

  public enum LoginReason {
    case unknown(Error)
    case noUserID
  }

  public enum AuthorizationReason {
    case photoLibrary
  }

  case network(NetworkReason)
  case login(LoginReason)
  case authorization(reason: AuthorizationReason)

}

extension VGError {

    public var errorDescription: String? {
        switch self {
        case .network(let reason):
            return reason.errorDescription
        case .login(let reason):
            return reason.errorDescription
        case .authorization(let reason):
            return reason.errorDescription
        }
    }
}

    extension VGError.NetworkReason {

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "错误的URL."
            case .invalidResponse:
                return "未知的返回内容."
            case .invalidURLHTTPResponse:
                return "错误的响应."
            case .default:
                return "服务器开小差了，请稍后再试."
            }
        }
    }

    extension VGError.LoginReason {

        var errorDescription: String? {
            switch self {
            case .unknown(let error):
                return error.localizedDescription
            case .noUserID:
                return "错误的用户."
            }
        }
    }

    extension VGError.AuthorizationReason {

        var errorDescription: String? {
            switch self {
            case .photoLibrary:
                return "相册未经授权"
            }
        }
    }


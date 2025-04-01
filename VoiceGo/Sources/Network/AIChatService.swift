import Alamofire
import Foundation
import Moya



// 定义Moya的Service
enum AIChatService {
    case chatMessages(parameters: [String: Any])
    case stopResponse(chatID: String)
    case getSession(sessionID: String)
    case messageFeedback(messageID: String, parameters: [String: Any])
    case getSessionList
    case getSessionHistory(sessionID: String)
    case deleteSession(sessionID: String)
    case speechToText(parameters: [String: Any])
    case textToSpeech(parameters: [String: Any])
}

extension AIChatService: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.dify.ai/v1")!
    }

    var path: String {
        switch self {
        case .chatMessages:
            return "chat-messages"
        case .stopResponse(let chatID):
            return "chat-messages/\(chatID)/stop"
        case .getSession(let sessionID):
            return "sessions/\(sessionID)"
        case .messageFeedback(let messageID, _):
            return "messages/\(messageID)/feedback"
        case .getSessionList:
            return "sessions"
        case .getSessionHistory(let sessionID):
            return "sessions/\(sessionID)/history"
        case .deleteSession(let sessionID):
            return "sessions/\(sessionID)"
        case .speechToText:
            return "speech-to-text"
        case .textToSpeech:
            return "text-to-speech"
        }
    }

    var method: Moya.Method {
        switch self {
        case .chatMessages, .messageFeedback, .speechToText, .textToSpeech:
            return .post
        case .stopResponse, .getSession, .getSessionList, .getSessionHistory:
            return .get
        case .deleteSession:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .chatMessages(let parameters),
             .messageFeedback(_, let parameters),
             .speechToText(let parameters),
             .textToSpeech(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .stopResponse, .getSession, .getSessionList, .getSessionHistory, .deleteSession:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer app-PpvVb5Nsdw1nipNu9yPRbkLx" // 替换为实际的API密钥
        ]
    }
}


// 添加MoyaProvider的异步扩展
extension MoyaProvider {
    func asyncRequest(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}

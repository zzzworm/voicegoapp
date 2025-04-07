import Alamofire
import Foundation
import Moya



// 定义Moya的Service
enum AIChatService {
    case sendChatMessage(messageReq : ChatMessageReq)
    case stopResponse(chatID: String)
    case getSession(sessionID: String)
    case messageFeedback(messageID: String, parameters: [String: Any])
    case getSessionList(user: String, last_id : String?, limit : Int, sort_by : String)
    case getMessageList(user: String, conversation_id: String, first_id : String?, limit : Int)
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
        case .sendChatMessage:
            return "chat-messages"
        case .stopResponse(let chatID):
            return "chat-messages/\(chatID)/stop"
        case .getSession(let sessionID):
            return "conversations/\(sessionID)"
        case .messageFeedback(let messageID, _):
            return "messages/\(messageID)/feedback"
        case .getSessionList(let user, _, _, _):
            return "conversations"
        case .getSessionHistory(let sessionID):
            return "conversations/\(sessionID)/history"
        case .deleteSession(let sessionID):
            return "conversations/\(sessionID)"
        case .speechToText:
            return "speech-to-text"
        case .textToSpeech:
            return "text-to-speech"
        case .getMessageList(user: let user,let conversation_id, first_id: let first_id, limit: let limit):
            return "messages"
        }
    }

    var method: Moya.Method {
        switch self {
        case .sendChatMessage, .messageFeedback, .speechToText, .textToSpeech:
            return .post
        case .stopResponse, .getSession, .getSessionList, .getMessageList, .getSessionHistory:
            return .get
        case .deleteSession:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .sendChatMessage(let messageReq):
            return .requestJSONEncodable(messageReq)
        case .messageFeedback(_, let parameters),
             .speechToText(let parameters),
             .textToSpeech(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .stopResponse, .getSession:
            return .requestPlain
        case .getSessionList(let user, let last_id, let limit, let sort_by):
            var parameters: [String: Any] = [
                "user": user,
                "limit": limit,
                "sort_by": sort_by
            ]
            if let last_id = last_id {
                parameters["last_id"] = last_id
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getMessageList(let user, let conversation_id, let first_id, let limit):
            var parameters: [String: Any] = [
                "conversation_id" : conversation_id,
                "user": user,
                "limit": limit,
            ]
            if let first_id = first_id {
                parameters["first_id"] = first_id
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getSessionHistory, .deleteSession:
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


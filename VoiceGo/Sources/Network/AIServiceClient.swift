//
//  AIServiceClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import Moya
import Alamofire



struct AIServiceClient {
    var sendChatMessage: @Sendable (String, ResponseMode, @escaping (DataStreamRequest.EventSource) -> Void) -> DataStreamRequest
    var stopResponse: @Sendable (String) async throws -> Response
    var getSession: @Sendable (String) async throws -> Response
    var messageFeedback: @Sendable (String, [String: Any]) async throws -> Response
    var getSessionList: @Sendable (ConversationQuery) async throws -> Response
    var getMessageList: @Sendable (MessageQuery) async throws -> Response
    var getSessionHistory: @Sendable (String) async throws -> Response
    var deleteSession: @Sendable (String) async throws -> Response
    var speechToText: @Sendable ([String: Any]) async throws -> Response
    var textToSpeech: @Sendable ([String: Any]) async throws -> Response

    struct Failure: Error, Equatable {}
}

// 使用Moya实现AIServiceClient的liveValue
extension AIServiceClient : DependencyKey {
    
    static var provider =  MoyaProvider<AIChatService>()
    /*{
        let sseRequestClosure = { (endpoint: Endpoint, closure: @escaping MoyaProvider.RequestResultClosure) in
            do {
                let urlRequest = try endpoint.urlRequest()
                let afRequest = AF.eventSourceRequest(urlRequest.url!, method: HTTPMethod(rawValue: urlRequest.httpMethod!)) 
                closure(.success(afRequest.request!))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
        let provider = MoyaProvider<AIChatService>(requestClosure: sseRequestClosure)
        return provider
    }
     */
    static let liveValue = Self(
        sendChatMessage: { query, responseMode, handler in
            let messageReq = ChatMessageReq(
                user: "a5e5f0cc-6ee7-4aad-af69-56fa085ee3f6",
                query: query
            )
            return provider.sseRequest(.sendChatMessage(messageReq: messageReq), handler:handler)
        },
        stopResponse: { chatID in
            
            return try await provider.asyncRequest(.stopResponse(chatID: chatID))
        },
        getSession: { sessionID in
            return try await provider.asyncRequest(.getSession(sessionID: sessionID))
        },
        messageFeedback: { messageID, parameters in
            return try await provider.asyncRequest(.messageFeedback(messageID: messageID, parameters: parameters))
        },
        getSessionList: { query in
            return try await provider.asyncRequest(.getSessionList(user: query.user, last_id: query.last_id, limit: query.limit, sort_by: query.sort_by.rawValue))
        },
        getMessageList: { query in
            return try await provider.asyncRequest(.getMessageList(user: query.user, conversation_id: query.conversation_id, first_id: query.first_id_id, limit: query.limit))
        },
        getSessionHistory: { sessionID in
            return try await provider.asyncRequest(.getSessionHistory(sessionID: sessionID))
        },
        deleteSession: { sessionID in
            return try await provider.asyncRequest(.deleteSession(sessionID: sessionID))
        },
        speechToText: { parameters in
            return try await provider.asyncRequest(.speechToText(parameters: parameters))
        },
        textToSpeech: { parameters in
            return try await provider.asyncRequest(.textToSpeech(parameters: parameters))
        }
    )
}

extension AIServiceClient {
    static var previewValue = Self(
        sendChatMessage: { query, responseMode, handler  in
            let messageReq = ChatMessageReq(
                user: "a5e5f0cc-6ee7-4aad-af69-56fa085ee3f6",
                query: query
            )
            return provider.sseRequest(.sendChatMessage(messageReq: messageReq), handler:handler)
        },
        stopResponse: { _ in Response(statusCode: 200, data: Data()) },
        getSession: { _ in Response(statusCode: 200, data: Data()) },
        messageFeedback: { _, _ in Response(statusCode: 200, data: Data()) },
        getSessionList: { _ in
            Response(statusCode: 200, data: Data())
        },
        getMessageList: { _ in Response(statusCode: 200, data: Data()) },
        getSessionHistory: { _ in Response(statusCode: 200, data: Data()) },
        deleteSession: { _ in Response(statusCode: 200, data: Data()) },
        speechToText: { _ in Response(statusCode: 200, data: Data()) },
        textToSpeech: { _ in Response(statusCode: 200, data: Data()) }
    )
}

extension AIServiceClient: TestDependencyKey {
    static var testValue = Self(
        sendChatMessage: { query, responseMode, handler  in
            let messageReq = ChatMessageReq(
                user: "a5e5f0cc-6ee7-4aad-af69-56fa085ee3f6",
                query: query
            )
            return provider.sseRequest(.sendChatMessage(messageReq: messageReq), handler:handler)
        },
        stopResponse: { _ in Response(statusCode: 200, data: Data()) },
        getSession: { _ in Response(statusCode: 200, data: Data()) },
        messageFeedback: { _, _ in Response(statusCode: 200, data: Data()) },
        getSessionList: {_ in
            Response(statusCode: 200, data: Data())
        },
        getMessageList: { _ in
            Response(statusCode: 200, data: Data())
        },
        getSessionHistory: { _ in Response(statusCode: 200, data: Data()) },
        deleteSession: { _ in Response(statusCode: 200, data: Data()) },
        speechToText: { _ in Response(statusCode: 200, data: Data()) },
        textToSpeech: { _ in Response(statusCode: 200, data: Data()) }
    )
}

extension DependencyValues {
    var aiServiceClient: AIServiceClient {
        get { self[AIServiceClient.self] }
        set { self[AIServiceClient.self] = newValue }
    }
}

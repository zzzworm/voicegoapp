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
    var sendChatMessage: @Sendable ([String: Any]) async throws -> Response
    var stopResponse: @Sendable (String) async throws -> Response
    var getSession: @Sendable (String) async throws -> Response
    var messageFeedback: @Sendable (String, [String: Any]) async throws -> Response
    var getSessionList: @Sendable () async throws -> Response
    var getSessionHistory: @Sendable (String) async throws -> Response
    var deleteSession: @Sendable (String) async throws -> Response
    var speechToText: @Sendable ([String: Any]) async throws -> Response
    var textToSpeech: @Sendable ([String: Any]) async throws -> Response

    struct Failure: Error, Equatable {}
}

// 使用Moya实现AIServiceClient的liveValue
extension AIServiceClient {
    
    static var provider :  MoyaProvider<AIChatService> {
        let sseRequestClosure = { (endpoint: Endpoint, closure: @escaping MoyaProvider.RequestResultClosure) in
            do {
                let urlRequest = try endpoint.urlRequest()
                let afRequest = AF.eventSourceRequest(urlRequest.url!, method: HTTPMethod(rawValue: urlRequest.httpMethod!))  // 使用 Alamofire.streamRequest‌:ml-citation{ref="2,8" data="citationList"}
                closure(.success(afRequest.request!))
            } catch {
                closure(.failure(MoyaError.underlying(error, nil)))
            }
        }
        let provider = MoyaProvider<AIChatService>(requestClosure: sseRequestClosure)
        return provider
    }
    static let liveValue = Self(
        sendChatMessage: { parameters in
            
            return try await provider.asyncRequest(.chatMessages(parameters: parameters))
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
        getSessionList: {
            return try await provider.asyncRequest(.getSessionList)
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
        sendChatMessage: { _ in Response(statusCode: 200, data: Data()) },
        stopResponse: { _ in Response(statusCode: 200, data: Data()) },
        getSession: { _ in Response(statusCode: 200, data: Data()) },
        messageFeedback: { _, _ in Response(statusCode: 200, data: Data()) },
        getSessionList: { Response(statusCode: 200, data: Data()) },
        getSessionHistory: { _ in Response(statusCode: 200, data: Data()) },
        deleteSession: { _ in Response(statusCode: 200, data: Data()) },
        speechToText: { _ in Response(statusCode: 200, data: Data()) },
        textToSpeech: { _ in Response(statusCode: 200, data: Data()) }
    )
}

extension AIServiceClient: TestDependencyKey {
    static var testValue = Self(
        sendChatMessage: { _ in Response(statusCode: 200, data: Data()) },
        stopResponse: { _ in Response(statusCode: 200, data: Data()) },
        getSession: { _ in Response(statusCode: 200, data: Data()) },
        messageFeedback: { _, _ in Response(statusCode: 200, data: Data()) },
        getSessionList: { Response(statusCode: 200, data: Data()) },
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

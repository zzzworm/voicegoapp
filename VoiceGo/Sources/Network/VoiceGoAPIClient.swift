//
//  VoiceGoAPIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import SwiftyJSON
import StrapiSwift
import Alamofire

struct VoiceGoAPIClient {
    var fetchStudyTools:  @Sendable (String) async throws -> StrapiResponse<[StudyTool]>
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var getToolConversationList:  @Sendable (_ studyToolId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[ToolConversation]>
    var createToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> StrapiResponse<ToolConversation>
    var streamToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> AsyncThrowingStream<DataStreamRequest.EventSourceEvent, Error>
    struct Failure: Error, Equatable {}
}

func handleStrapiRequest<T: Decodable & Sendable>(_ action: @Sendable () async throws -> StrapiResponse<T>) async rethrows -> StrapiResponse<T> {
    do {
        let response = try await action()
        return response
    } catch {
        switch error {
        case let strapiError as StrapiSwiftError:

                switch strapiError {
                case .badResponse(let statusCode, let message):
                    if statusCode > 400 && statusCode < 500 {
                        @Dependency(\.notificationCenter) var notificationCenter
                        print("Bad response: \(statusCode)")
                        notificationCenter.post(.signOut, nil, nil)
                    }
                    print("Bad response: \(message)")
                case .decodingError(let decodingError):
                    print("Unauthorized")
                case .unknownError(let unknownError):
                    print("Unknown error: \(unknownError)")
                case .noDataAvailable:
                    print("No data available")
                default:
                    print("Strapi Error: \(strapiError)")
                }
            
        default:
            print("request Error: \(error)")
        }
        throw error
    }
}


// 使用Moya实现APIClient的liveValue
extension VoiceGoAPIClient : DependencyKey  {
    
    
    
    static let liveValue = Self(
        fetchStudyTools: { category in
            return try await handleStrapiRequest{
                let resp =  try await Strapi.contentManager.collection("study-tools")
                    .filter("[categoryTag]", operator: .equal, value: category)
                    .populate("exampleCard")
                    .getDocuments(as: [StudyTool].self)
            return resp
        }},
        fetchUserProfile: {
            let response = try await Strapi.authentication.local.me(as: UserProfile.self)
            let profile = response
            return profile
        },
        getToolConversationList: {studyToolId, page, pageSize in
            let response = try await Strapi.contentManager.collection("tool-conversation/my-list")
                .filter("[study_tool_user_used][studyTool][documentId]",operator: .equal, value:studyToolId)
                .paginate(page: page, pageSize: pageSize)
                .getDocuments(as: [ToolConversation].self)
            return response
        },
        createToolConversation: {studyTool, query in
            
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId)]), "query": .string(query)]);
            let response = try await Strapi.contentManager.collection("tool-conversation").postData(data, as: ToolConversation.self)
            return response
        },
        streamToolConversation: {studyTool, query in
    
            return AsyncThrowingStream() { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                return continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: 503, message: errorMessage))
                            }
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            
                        }
                    })
                }
            }
        }
    )
}



extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: { _ in

            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
                data: StudyTool.sample,
                meta: meta
            )
            return resp
        },
        fetchUserProfile: {
            let profile = UserProfile.sample
            return profile
        },
        getToolConversationList: { studyToolUsedId,  page, pageSize in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)
            let resp =  StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { studyTool, query in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: {studyTool, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            if let httpResponse = completion.response, let request = completion.request{
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            }
                        }
                    })
                }
            }
        }
    )
}

extension VoiceGoAPIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: { _ in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
                data: StudyTool.sample,
                meta: meta
            )
            return resp
        },
        fetchUserProfile: {
            let profile = UserProfile.sample
            return profile
        },
        getToolConversationList: {studyToolUsedId, page, pageSize in
            // 构造 Pagination 实例
            let pagination = Pagination(page: 1, pageSize: 10, pageCount: 1, limit: 10, start: 0, total: 1)

            // 构造 Meta 实例
            let meta = Meta(pagination: pagination)


            let resp =  StrapiResponse(
                data: ToolConversation.sample,
                meta: meta
            )
            return resp
        },
        createToolConversation: { studyTool, query in
            let response = StrapiResponse(
                data: ToolConversation.sample[0],
                meta: nil
            )
            return response
        },
        streamToolConversation: {studyTool, query in
            return AsyncThrowingStream { continuation in
                Task {
                    let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
                    let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
                    
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(let message):
                            break;
                        case .complete(let completion):
                            if let httpResponse = completion.response, let request = completion.request{
                                if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                    let errorMessage = "Bad Response"
                                    continuation.finish( throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                                }
                                else{
                                    continuation.finish()
                                }
                            }
                        }
                    })
                }
            }
        }
    )
}

extension DependencyValues {
    var apiClient: VoiceGoAPIClient {
        get { self[VoiceGoAPIClient.self] }
        set { self[VoiceGoAPIClient.self] = newValue }
    }
}

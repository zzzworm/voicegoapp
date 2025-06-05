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
    var updateUserProfile:  @Sendable (UserProfile) async throws -> UserProfile
    var getAliSTS: @Sendable () async throws -> AliOSSSTS
    
    var getToolConversationList:  @Sendable (_ studyToolId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[ToolConversation]>
    var createToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> StrapiResponse<ToolConversation>
    var streamToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> AsyncThrowingStream<DataStreamRequest.EventSourceEvent, Error>

    var createAITeacherConversation:  @Sendable (_ aiTeacher : AITeacher ,_ query: String) async throws -> StrapiResponse<AITeacherConversation>
    var streamAITeacherConversation:  @Sendable (_ aiTeacher : AITeacher ,_ query: String) async throws -> AsyncThrowingStream<DataStreamRequest.EventSourceEvent, Error>
    var getAITeacherConversationList:  @Sendable (_ aiTeacherId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[AITeacherConversation]>
    var fetchAITeachers: @Sendable () async throws -> StrapiResponse<[AITeacher]>
    
    var streamSenceConversation: @Sendable (_ scene: ConversationScene, _ query: String) async throws -> AsyncThrowingStream<DataStreamRequest.EventSourceEvent, Error>
    var getSenceConversationList: @Sendable (_ sceneId: String, _ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[SceneConversation]>
    var fetchSenceList: @Sendable (String) async throws -> StrapiResponse<[ConversationScene]>
    
    struct Failure: Error, Equatable {}
}

func handleStrapiRequest<T: Decodable & Sendable>(_ action: @Sendable () async throws -> T) async rethrows -> T {
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
            return try await handleStrapiRequest{
                let response = try await Strapi.authentication.local.me(as: UserProfile.self)
                return response
            }
        },
        updateUserProfile: { profile in
            var updateData : [String: AnyCodable] = [:]
            if !profile.username.isEmpty {
                updateData["username"] = .string(profile.username)
            }
            if !profile.email.isEmpty {
                updateData["email"] = .string(profile.email)
            }
            if let city = profile.city, !city.isEmpty {
                updateData["city"] = .string(city)
            }
            if let userIconUrl = profile.userIconUrl, !userIconUrl.isEmpty {
                updateData["userIconUrl"] = .string(userIconUrl)
            }
            updateData["sex"] = .string(profile.sex.rawValue)
            let data = StrapiRequestBody(updateData)
            let response = try await Strapi.authentication.local.me(extendUrl: "", requestType: .PUT, data: data, as: UserProfile.self)
            return profile
        },
        getAliSTS: {
            let resp = try await Strapi.contentManager.collection("ali-cloud-sts").withDocumentId("").getDocument(as: AliOSSSTS.self)
            return resp.data
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
        },
        createAITeacherConversation: { aiTeacher, query in
            let data = StrapiRequestBody(["ai_teacher": .dictionary(["documentId":.string(aiTeacher.documentId)]), "query": .string(query)]);
            let response = try await Strapi.contentManager.collection("tool-conversation").postData(data, as: AITeacherConversation.self)
            return response
        },
        streamAITeacherConversation: { aiTeacher, query in
            
            return AsyncThrowingStream() { continuation in
                Task {
                    let categoryKey = aiTeacher.card?.categoryKey ?? "教练对话"
                    let assist_content = aiTeacher.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "ai_teacher": .dictionary([
                            "documentId": .string(aiTeacher.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("teacher-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(_): break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, message: errorMessage))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getAITeacherConversationList: { aiTeacherId, page, pageSize in
            let response = try await Strapi.contentManager.collection("teacher-conversation/my-list")
                .filter("[ai_teacher][documentId]", operator: .equal, value: aiTeacherId)
                .paginate(page: page, pageSize: pageSize)
                .getDocuments(as: [AITeacherConversation].self)
            return response
        },
        fetchAITeachers: {
            return try await handleStrapiRequest {
                let resp = try await Strapi.contentManager.collection("ai-teachers")
                    .populate("card")
                    .getDocuments(as: [AITeacher].self)
                return resp
            }
        },
        streamSenceConversation: { scene, query in
            return AsyncThrowingStream() { continuation in
                Task {
                    let categoryKey = scene.card?.categoryKey ?? "场景对话"
                    let assist_content = scene.card?.assistContent ?? "请根据用户的提问，给出专业的回答"
                    let data = StrapiRequestBody([
                        "scene": .dictionary([
                            "documentId": .string(scene.documentId),
                            "categoryKey": .string(categoryKey),
                            "assist_content": .string(assist_content)
                        ]),
                        "query": .string(query)
                    ])
                    let request = try await Strapi.contentManager.collection("scene-conversation/create-message?stream").asPostRequest(data)
                    Session.default.eventSourceRequest(request).responseEventSource(handler: { eventSource in
                        continuation.yield(eventSource.event)
                        switch eventSource.event {
                        case .message(_): break
                        case .complete(let completion):
                            guard let httpResponse = completion.response else {
                                let errorMessage = "Bad Response"
                                return continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: 503, message: errorMessage))
                            }
                            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 && httpResponse.statusCode != 204 {
                                let errorMessage = "Bad Response"
                                continuation.finish(throwing: StrapiSwiftError.badResponse(statusCode: httpResponse.statusCode, message: errorMessage))
                            } else {
                                continuation.finish()
                            }
                        }
                    })
                }
            }
        },
        getSenceConversationList: { sceneId, page, pageSize in
            let response = try await Strapi.contentManager.collection("scene-conversation/my-list")
                .filter("[scene][documentId]", operator: .equal, value: sceneId)
                .paginate(page: page, pageSize: pageSize)
                .getDocuments(as: [SceneConversation].self)
            return response
        },
        fetchSenceList: { categoryRawValue in
            return try await handleStrapiRequest {
                let resp = try await Strapi.contentManager.collection("scenes")
                    .filter("[tags]", operator: .contains, value: categoryRawValue)
                    .populate("card")
                    .getDocuments(as: [ConversationScene].self)
                return resp
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

// swiftlint:enable line_length

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
    var fetchStudyTools:  @Sendable () async throws -> StrapiResponse<[StudyTool]>
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var getToolConversationList:  @Sendable (_ studyToolId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[ToolConversation]>
    var createToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String) async throws -> StrapiResponse<ToolConversation>
    var streamToolConversation:  @Sendable (_ studyTool : StudyTool ,_ query: String , @escaping (DataStreamRequest.EventSource) -> Void) async throws -> DataStreamRequest
    struct Failure: Error, Equatable {}
}

// 使用Moya实现APIClient的liveValue
extension VoiceGoAPIClient : DependencyKey  {
    
    static let liveValue = Self(
        fetchStudyTools: {
            let resp =  try await Strapi.contentManager.collection("study-tools").populate("exampleCard").getDocuments(as: [StudyTool].self)
            return resp
        },
        fetchUserProfile: {
            let response = try await Strapi.authentication.local.me(as: UserProfile.self)
            let profile = response
            return profile
        },
        getToolConversationList: {studyToolId, page, pageSize in
            let response = try await Strapi.contentManager.collection("tool-conversation/my-list").filter("study_tool_user_used",operator: .equal, value:["studyTool":studyToolId]).paginate(page: page, pageSize: pageSize).getDocuments(as: [ToolConversation].self)
            return response
        },
        createToolConversation: {studyTool, query in
            
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId)]), "query": .string(query)]);
            let response = try await Strapi.contentManager.collection("tool-conversation").postData(data, as: ToolConversation.self)
            return response
        },
        streamToolConversation: {studyTool, query, handler in
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
            let request = try await Strapi.contentManager.collection("tool-conversation/create-message?stream").asPostRequest(data)
            
            return Session.default.eventSourceRequest(request).responseEventSource(handler: handler)
        }
    )
}



extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: {

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
        streamToolConversation: { studyTool, query, handler in
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
            let request = try await Strapi.contentManager.collection("tool-conversation/create-message").withFields(["stream"]).asPostRequest(data)
            
            return Session.default.eventSourceRequest(request).responseEventSource(handler: handler)
        }
    )
}

extension VoiceGoAPIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: {
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
        streamToolConversation: { studyTool, query, handler in
            let data = StrapiRequestBody(["studyTool": .dictionary(["documentId":.string(studyTool.documentId),"categoryKey":.string(studyTool.categoryKey)]), "query": .string(query)]);
            let request = try await Strapi.contentManager.collection("tool-conversation/create-message").withFields(["stream"]).asPostRequest(data)
            
            return Session.default.eventSourceRequest(request).responseEventSource(handler: handler)
        }
    )
}

extension DependencyValues {
    var apiClient: VoiceGoAPIClient {
        get { self[VoiceGoAPIClient.self] }
        set { self[VoiceGoAPIClient.self] = newValue }
    }
}

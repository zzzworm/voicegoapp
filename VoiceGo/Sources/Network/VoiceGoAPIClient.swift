//
//  VoiceGoAPIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import Moya
import SwiftyJSON
import StrapiSwift

struct VoiceGoAPIClient {
    var fetchStudyTools:  @Sendable () async throws -> StrapiResponse<[StudyToolUsed]>
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    var getToolConversationList:  @Sendable (_ studyToolUsedId : String ,_ page: Int, _ pageSize: Int) async throws -> StrapiResponse<[ToolConversation]>
    struct Failure: Error, Equatable {}
}

// 使用Moya实现APIClient的liveValue
extension VoiceGoAPIClient : DependencyKey  {
    static var provider :  MoyaProvider<APIService>{
        @Dependency(\.session) var session
        @Dependency(\.userKeychainClient) var userKeychainClient
        let token = userKeychainClient.retrieveToken()
        let provider = MoyaProvider<APIService>(session: session,plugins: [
            NetworkLoggerPlugin(
                configuration: .init(logOptions: .verbose)
            ),
            AccessTokenPlugin {_ in token ?? ""}])
        return provider
    }
    
    static let liveValue = Self(
        fetchStudyTools: {
            let resp =  try await Strapi.contentManager.collection("study-tool-user-useds/my-list").getDocuments(as: [StudyToolUsed].self)
            return resp
        },
        fetchUserProfile: {
            let response = try await Strapi.contentManager.collection("users/me").getDocuments(as: UserProfile.self)
            let profile = response.data
            return profile
        },
        getToolConversationList: {studyToolUsedId, page, pageSize in
            let response = try await Strapi.contentManager.collection("tool-conversation/my-list").paginate(page: page, pageSize: pageSize).getDocuments(as: [ToolConversation].self)
            return response
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
                data: StudyToolUsed.sample,
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
                data: StudyToolUsed.sample,
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
        }
    )
}

extension DependencyValues {
    var apiClient: VoiceGoAPIClient {
        get { self[VoiceGoAPIClient.self] }
        set { self[VoiceGoAPIClient.self] = newValue }
    }
}

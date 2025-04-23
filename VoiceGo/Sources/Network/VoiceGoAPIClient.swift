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
        }
    )
}


extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: {
            return try await Strapi.contentManager.collection("study-tool-user-useds/my-list").getDocuments(as: [StudyToolUsed].self)
        },
        fetchUserProfile: { .sample }
    )
}

extension VoiceGoAPIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: {
            return try await Strapi.contentManager.collection("study-tool-user-useds/my-list").getDocuments(as: [StudyToolUsed].self)
        },
        fetchUserProfile: { .sample }
    )
}

extension DependencyValues {
    var apiClient: VoiceGoAPIClient {
        get { self[VoiceGoAPIClient.self] }
        set { self[VoiceGoAPIClient.self] = newValue }
    }
}

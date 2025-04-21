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

struct VoiceGoAPIClient {
    var fetchStudyTools:  @Sendable () async throws -> [StudyTool]
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
            let response = try await provider.asyncRequest(.fetchStudyTools)
            let listRsp = try JSONDecoder().decode(ListResponse<StudyTool>.self, from: response.data)
            
            let products = listRsp.data
            
            return products
        },
        fetchUserProfile: {
            let response = try await provider.asyncRequest(.fetchUserProfile)
            let profile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            return profile
        }
    )
}


extension VoiceGoAPIClient {
    static var previewValue = Self(
        fetchStudyTools: {
            StudyTool.sample
        },
        fetchUserProfile: { .sample }
    )
}

extension VoiceGoAPIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: {
            StudyTool.sample
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

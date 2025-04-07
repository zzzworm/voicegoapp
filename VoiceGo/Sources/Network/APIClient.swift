//
//  APIClient.swift
//  OnlineStoreTCA
//
//  Created by Pedro Rojas on 23/08/22.
//

import Foundation
import ComposableArchitecture
import Moya

struct APIClient {
    var fetchStudyTools:  @Sendable () async throws -> [StudyTool]
    var fetchUserProfile:  @Sendable () async throws -> UserProfile
    
    struct Failure: Error, Equatable {}
}

// 使用Moya实现APIClient的liveValue
extension APIClient/* : DependencyKey */ {
    static let liveValue = Self(
        fetchStudyTools: {
            let provider = MoyaProvider<APIService>()
            let response = try await provider.asyncRequest(.fetchStudyTools)
            let products = try JSONDecoder().decode([StudyTool].self, from: response.data)
            return products
        },
        fetchUserProfile: {
            let provider = MoyaProvider<APIService>()
            let response = try await provider.asyncRequest(.fetchUserProfile)
            let profile = try JSONDecoder().decode(UserProfile.self, from: response.data)
            return profile
        }
    )
}


extension APIClient {
    static var previewValue = Self(
        fetchStudyTools: {
            StudyTool.sample
        },
        fetchUserProfile: { .sample }
    )
}

extension APIClient : TestDependencyKey  {
    static var testValue = Self(
        fetchStudyTools: {
            StudyTool.sample
        },
        fetchUserProfile: { .sample }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
